# resource "aws_dynamodb_table" "UsersSigninData" {
#   name           = "UsersSigninData"
#   read_capacity  = 1  // update as per your requirement
#   write_capacity = 1  // update as per your requirement
#   hash_key       = "Username"
#   range_key      = "SigninTime"
#   stream_enabled   = true
#   stream_view_type = "NEW_IMAGE"

#   attribute {
#     name = "Username"
#     type = "S"
#   }

#   attribute {
#     name = "SigninTime"
#     type = "S"
#   }

#   point_in_time_recovery {
#     enabled = true
#   }

#   lifecycle {
#     create_before_destroy = true
#   }
# }
