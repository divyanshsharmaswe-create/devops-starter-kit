output "cluster" {
  value = aws_ecs_cluster.this.name
}

output "service" {
  value = aws_ecs_service.api.name
}

output "logs" {
  value = aws_cloudwatch_log_group.api.name
}
