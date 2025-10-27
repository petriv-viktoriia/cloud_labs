resource "random_password" "user_pass" {
  length = 16
  special = true
  override_special = "!@#%^*()-_+="
}

resource "azuread_user" "az104_user1" {
  user_principal_name = "az104-user1@${var.domain_name}"
  display_name = "az104-user1"
  password = random_password.user_pass.result

  force_password_change = false
  account_enabled = true

  job_title = var.job_title
  department = var.department
  usage_location = "US"
}

resource "azuread_invitation" "guest" {
  user_email_address = var.guest_email
  user_display_name = var.guest_name
  redirect_url = "https://portal.azure.com"
  message {
    body = "Welcome to Azure and our group project"
  }
}

resource "azuread_group" "it_lab_admins" {
  display_name = "IT Lab Administrators"
  description = "Administrators that manage the IT lab"
  security_enabled = true
}

resource "azuread_group_member" "az104_user1_member" {
  group_object_id = azuread_group.it_lab_admins.object_id
  member_object_id = azuread_user.az104_user1.object_id
}

resource "azuread_group_member" "guest_member" {
  count = var.guest_email != "" ? 1 : 0

  group_object_id = azuread_group.it_lab_admins.object_id
  member_object_id = azuread_invitation.guest.user_id

  depends_on = [ azuread_invitation.guest ]
}