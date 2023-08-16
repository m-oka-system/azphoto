terraform {
  cloud {
    organization = "m-oka-system"

    workspaces {
      name = "azphoto"
    }
  }
}
