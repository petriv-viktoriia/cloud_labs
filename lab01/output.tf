output "az104_user1_id" {
  value = azuread_user.az104_user1.id
}

output "az104_user1_name" {
  value = azuread_user.az104_user1.user_principal_name
}

output "az104_user1_pass" {
  value = random_password.user_pass.result
  sensitive = true
}

output "guest_email" {
  value = azuread_invitation.guest.user_email_address
}

output "group_id" {
  value = azuread_group.it_lab_admins
}

output "group_name" {
  value = azuread_group.it_lab_admins.display_name
}