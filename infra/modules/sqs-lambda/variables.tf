variable "functions" {
  type = list(object({
    function_name  = string
    image_uri      = string
    timeout        = number
    memory_size    = number
    function_color = string
    queue_arn      = string
  }))
}
