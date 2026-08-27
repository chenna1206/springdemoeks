resource "aws_vpc" "spring_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    var.tags,
    {
      Name = "${var.app_short}-vpc-${var.environment}"
    }
  )
}

resource "aws_subnet" "spring_subnet" {
  vpc_id                  = aws_vpc.spring_vpc.id
  count                   = length(var.availability_zones)
  cidr_block              = cidrsubnet(aws_vpc.spring_vpc.cidr_block, 8, count.index)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.app_short}-subnet-${count.index + 1}-${var.environment}"
  }
}

resource "aws_internet_gateway" "spring_boot_igw" {
  vpc_id = aws_vpc.spring_vpc.id

  tags = merge(
    var.tags,
    {
      Name = "${var.app_short}-igw-${var.environment}"
    }
  )
}


resource "aws_route_table" "spring_route_table" {
  vpc_id = aws_vpc.spring_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.spring_boot_igw.id
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.app_short}-route-table-${var.environment}"
    }
  )
}

resource "aws_route_table_association" "spring_route_table_association" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.spring_subnet[count.index].id
  route_table_id = aws_route_table.spring_route_table.id
}

resource "aws_security_group" "spring_sg" {
  name        = "${var.app_short}-sg-${var.environment}"
  description = "Security group for ${var.app_short} in ${var.environment}"
  vpc_id      = aws_vpc.spring_vpc.id

  ingress {
    from_port   = 9191
    to_port     = 9191
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_short}-sg-${var.environment}"
  }
}

resource "aws_ecr_repository" "springboot" {
  name = "springboot-app"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.app_short}-ecr-${var.environment}"
    }
  )
}

resource "aws_iam_role" "ec2_role" {
  name = "${var.app_short}-ec2-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_ecr" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}


resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.app_short}-ec2-profile-${var.environment}"
  role = aws_iam_role.ec2_role.name
}


resource "aws_instance" "spring_ec2" {

  ami           = "ami-01a00762f46d584a1"
  instance_type = "t3.micro"

  subnet_id = aws_subnet.spring_subnet[0].id

  vpc_security_group_ids = [
    aws_security_group.spring_sg.id
  ]

  key_name = var.key_name

  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  user_data = file("${path.module}/user-data.sh")

  tags = {
    Name = "springboot-server"
  }
}