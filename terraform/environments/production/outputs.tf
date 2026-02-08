output "server_ip" {
  description = "Public IP address of the VPS"
  value       = openstack_compute_instance_v2.server.access_ip_v4
}

output "ssh_command" {
  description = "SSH command to connect to the server"
  value       = "ssh root@${openstack_compute_instance_v2.server.access_ip_v4}"
}

output "app_url" {
  description = "Application URL"
  value       = "https://blog.okunichiyou.com"
}
