resource "aws_s3_bucket" "commit_project" {
  bucket = "commit-project-ilan-moshe"

  tags = {
    Name = "project bucket"
    Environment = "Production"
  }
}


