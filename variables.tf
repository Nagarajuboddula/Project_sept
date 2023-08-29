variable "awsprops" {
    type = "map"
    default = {
    region = "us-east-1"
    ami = "ami-0c1bea58988a989155"
    ami1 = ""
    itype = "t2.micro"
    publicip = true
    keyname = "myseckey"
    secgroupname = "IAC-Sec-Group"
  }
}