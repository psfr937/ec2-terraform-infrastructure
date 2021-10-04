resource "aws_security_group" "alb" {
  name   = "${var.service_name}-allow-http"
  vpc_id = "${aws_vpc.this.id}"

  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.service_name}-allow-http"
  }
}

resource "aws_lb" "this" {
  name               = "${var.service_name}-service-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.alb.id}"]
  subnets            = "${aws_subnet.public.*.id}"

  tags = {
    Name = "${var.service_name}-service-alb"
  }
}


resource "aws_lb_listener" "this" {
  load_balancer_arn = "${aws_lb.this.arn}"
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

resource "aws_lb_listener" "https" {
  load_balancer_arn = "${aws_lb.this.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${aws_acm_certificate.this.arn}"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.this.0.arn}"
  }

  depends_on = ["aws_acm_certificate.this"]
}

resource "aws_lb_listener_rule" "this" {
  count        = 2
  listener_arn = "${aws_lb_listener.this.arn}"

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.this.*.arn[count.index]}"
  }

  condition {
    host_header {
      values = "${local.hosts_name}"
    }
  }
}

resource "aws_lb_target_group" "this" {
  count = "${length(local.target_groups)}"
  name  = "${var.service_name}-tg-${element(local.target_groups, count.index)}"

  port        = 80
  protocol    = "HTTP"
  vpc_id      = "${aws_vpc.this.id}"
  target_type = "instance"

  health_check {
    path = "/"
  }
}
