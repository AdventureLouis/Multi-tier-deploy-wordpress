# Create a public hosted zone
resource "aws_route53_zone" "main" {
  name = "lab-loui.org"  # Replace with your domain name

  # Add a lifecycle block to prevent accidental deletion
  #   lifecycle {
  #   prevent_destroy = true
  # }


  tags = {
    Environment = "dev"
    Project     = "my-website"
    ManagedBy   = "terraform"
    Critical    = "true"
  }
  
}


# Update the registered domain's nameservers
resource "aws_route53domains_registered_domain" "domain" {
    provider = aws.route53-domains
  domain_name = "lab-loui.org"

 dynamic "name_server" {
    for_each = aws_route53_zone.main.name_servers
    content {
      name = name_server.value
    }
  }

  depends_on = [aws_route53_zone.main]
}

# Optional: Create an A record with alias (e.g., for ALB/CloudFront)
resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "lab-loui.org"
  type    = "A"

  alias {
    name                   = aws_lb.wordpress_alb.dns_name 
    zone_id                = aws_lb.wordpress_alb.zone_id 
    evaluate_target_health = true
  }
    depends_on = [aws_route53_zone.main, aws_lb.wordpress_alb,aws_route53domains_registered_domain.domain]
}

# include a subdomain so that my website can also be viewed with www
resource "aws_route53_record" "www_subdomain" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www.lab-loui.org"
  type    = "A"

  alias {
    name                   = aws_lb.wordpress_alb.dns_name 
    zone_id                = aws_lb.wordpress_alb.zone_id 
    evaluate_target_health = true
  }
  depends_on = [aws_route53_zone.main, aws_lb.wordpress_alb]
}


#Create  HTTPS Listener for application load balancer
# Create ACM certificate
resource "aws_acm_certificate" "cert" {
  domain_name       = "lab-loui.org"
  validation_method = "DNS"

  subject_alternative_names = ["*.lab-loui.org"]  # Includes all subdomains

  tags = {
    Environment = "dev"
    Name        = "lab-loui-cert"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Create DNS records for certificate validation
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.main.zone_id
}

# Certificate validation
resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}


# HTTP Listener - Redirect to HTTPS
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.wordpress_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# HTTPS Listener
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.wordpress_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"  # Modern security policy
  certificate_arn   = aws_acm_certificate.cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wordpress_tg.arn
  }

  depends_on = [aws_acm_certificate_validation.cert]
}



