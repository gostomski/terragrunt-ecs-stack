#------------------------------------------------------------------------------
# Misc
#------------------------------------------------------------------------------
variable "name_prefix" {
  description = "Name prefix for resources on AWS"
}

#------------------------------------------------------------------------------
# AWS ECS Container Definition Variables
#------------------------------------------------------------------------------
variable "container_image" {
  description = "The image used to start the container."
}

variable "container_name" {
  description = "The name of the container. Up to 255 characters ([a-z], [A-Z], [0-9], -, _ allowed)"
}

variable "command" {
  description = "(Optional) The command that is passed to the container"
  type        = list(string)
  default     = null
}

variable "task_cpu" {
  description = "The number of cpu units to reserve for the task."
  default     = 1024
}

variable "container_cpu" {
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html#fargate-task-defs
  description = "(Optional) The number of cpu units to reserve for the container. This is optional for tasks using Fargate launch type and the total amount of container_cpu of all containers in a task will need to be lower than the task-level cpu value"
  default     = null # 1 vCPU
}

variable "container_depends_on" {
  description = "(Optional) The dependencies defined for container startup and shutdown. A container can contain multiple dependencies. When a dependency is defined for container startup, for container shutdown it is reversed"
  type = list(object({
    containerName = string
    condition     = string
  }))
  default = null
}

variable "task_memory" {
  description = "The amount of memory (in MiB) to allow the task to use." 
  default     = 2048
}

variable "container_memory" {
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html#fargate-task-defs
  description = "(Optional) The amount of memory (in MiB) to allow the container to use. This is a hard limit, if the container attempts to exceed the container_memory, the container is killed. This field is optional for Fargate launch type and the total amount of container_memory of all containers in a task will need to be lower than the task memory value"
  default     = null # 8 GB
}

variable "container_memory_reservation" {
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html#fargate-task-defs
  description = "(Optional) The amount of memory (in MiB) to reserve for the container. If container needs to exceed this threshold, it can do so up to the set container_memory hard limit"
  default     = null # 2 GB
}

variable "dns_servers" {
  type        = list(string)
  description = "(Optional) Container DNS servers. This is a list of strings specifying the IP addresses of the DNS servers"
  default     = null
}

variable "docker_labels" {
  description = "(Optional) The configuration options to send to the `docker_labels`"
  type        = map(string)
  default     = null
}

variable "entrypoint" {
  description = "(Optional) The entry point that is passed to the container"
  type        = list(string)
  default     = null
}

variable "environment" {
  description = "(Optional) The environment variables to pass to the container. This is a list of maps"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "essential" {
  description = "(Optional) Determines whether all other containers in a task are stopped, if this container fails or stops for any reason. Due to how Terraform type casts booleans in json it is required to double quote this value"
  type        = bool
  default     = true
}

# https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_FirelensConfiguration.html
variable "firelens_configuration" {
  description = "(Optional) The FireLens configuration for the container. This is used to specify and configure a log router for container logs. For more details, see https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_FirelensConfiguration.html"
  type = object({
    type    = string
    options = map(string)
  })
  default = null
}

# https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_HealthCheck.html
variable "healthcheck" {
  description = "(Optional) A map containing command (string), timeout, interval (duration in seconds), retries (1-10, number of times to retry before marking container unhealthy), and startPeriod (0-300, optional grace period to wait, in seconds, before failed healthchecks count toward retries)"
  type = object({
    command     = list(string)
    retries     = number
    timeout     = number
    interval    = number
    startPeriod = number
  })
  default = null
}

variable "links" {
  description = "(Optional) List of container names this container can communicate with without port mappings"
  type        = list(string)
  default     = null
}

# https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_LinuxParameters.html
variable "linux_parameters" {
  description = "Linux-specific modifications that are applied to the container, such as Linux kernel capabilities. For more details, see https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_LinuxParameters.html"
  type = object({
    capabilities = object({
      add  = list(string)
      drop = list(string)
    })
    devices = list(object({
      containerPath = string
      hostPath      = string
      permissions   = list(string)
    }))
    initProcessEnabled = bool
    maxSwap            = number
    sharedMemorySize   = number
    swappiness         = number
    tmpfs = list(object({
      containerPath = string
      mountOptions  = list(string)
      size          = number
    }))
  })

  default = null
}

# https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_LogConfiguration.html
variable "log_configuration" {
  description = "(Optional) Log configuration options to send to a custom log driver for the container. For more details, see https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_LogConfiguration.html"
  type = object({
    logDriver = string
    options   = map(string)
    secretOptions = list(object({
      name      = string
      valueFrom = string
    }))
  })
  default = null
}

variable "mount_points" {
  description = "(Optional) Container mount points. This is a list of maps, where each map should contain a `containerPath` and `sourceVolume`"
  type = list(object({
    containerPath = string
    sourceVolume  = string
  }))
  default = []
}

variable "port_mappings" {
  description = "The port mappings to configure for the container. This is a list of maps. Each map should contain \"containerPort\", \"hostPort\", and \"protocol\", where \"protocol\" is one of \"tcp\" or \"udp\". If using containers in a task with the awsvpc or host network mode, the hostPort can either be left blank or set to the same value as the containerPort"
  type = list(object({
    containerPort = number
    hostPort      = number
    protocol      = string
  }))
  default = []
}

variable "task_role_arn" {
  description = "(Optional) The ARN of IAM role that allows your Amazon ECS container task to make calls to other AWS services. If not specified, `aws_iam_role.ecs_task_execution_role.arn` is used"
  type        = string
  default     = null
}

variable "readonly_root_filesystem" {
  description = "(Optional) Determines whether a container is given read-only access to its root filesystem. Due to how Terraform type casts booleans in json it is required to double quote this value"
  type        = bool
  default     = false
}

variable "repository_credentials" {
  description = "(Optional) Container repository credentials; required when using a private repo.  This map currently supports a single key; \"credentialsParameter\", which should be the ARN of a Secrets Manager's secret holding the credentials"
  type        = map(string)
  default     = null
}

variable "secrets" {
  description = "(Optional) The secrets to pass to the container. This is a list of maps"
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default = null
}

variable "start_timeout" {
  description = "(Optional) Time duration (in seconds) to wait before giving up on resolving dependencies for a container."
  default     = 30
}

variable "system_controls" {
  description = "(Optional) A list of namespaced kernel parameters to set in the container, mapping to the --sysctl option to docker run. This is a list of maps: { namespace = \"\", value = \"\"}"
  type        = list(map(string))
  default     = null
}

variable "stop_timeout" {
  description = "(Optional) Timeout in seconds between sending SIGTERM and SIGKILL to container"
  type        = number
  default     = 30
}

variable "ulimits" {
  description = "(Optional) Container ulimit settings. This is a list of maps, where each map should contain \"name\", \"hardLimit\" and \"softLimit\""
  type = list(object({
    name      = string
    hardLimit = number
    softLimit = number
  }))
  default = null
}

variable "user" {
  description = "(Optional) The user to run as inside the container. Can be any of these formats: user, user:group, uid, uid:gid, user:gid, uid:group"
  type        = string
  default     = null
}

variable "volumes_from" {
  description = "(Optional) A list of VolumesFrom maps which contain \"sourceContainer\" (name of the container that has the volumes to mount) and \"readOnly\" (whether the container can write to the volume)"
  type = list(object({
    sourceContainer = string
    readOnly        = bool
  }))
  default = null
}

variable "working_directory" {
  description = "(Optional) The working directory to run commands inside the container"
  type        = string
  default     = null
}

#------------------------------------------------------------------------------
# AWS ECS Task Definition Variables
#------------------------------------------------------------------------------
variable "placement_constraints" {
  description = "(Optional) A set of placement constraints rules that are taken into consideration during task placement. Maximum number of placement_constraints is 10. This is a list of maps, where each map should contain \"type\" and \"expression\""
  type        = list
  default     = []
}

variable "proxy_configuration" {
  description = "(Optional) The proxy configuration details for the App Mesh proxy. This is a list of maps, where each map should contain \"container_name\", \"properties\" and \"type\""
  type        = list
  default     = []
}

variable "volumes" {
  description = "(Optional) A set of volume blocks that containers in your task may use"
  type = list(object({
    host_path = string
    name      = string
    docker_volume_configuration = list(object({
      autoprovision = bool
      driver        = string
      driver_opts   = map(string)
      labels        = map(string)
      scope         = string
    }))
    efs_volume_configuration = list(object({
      file_system_id = string
      root_directory = string
    }))
  }))
  default = []
}

variable "dynamo_db_table_arn" {
  description = "ARN of the DynamoDB table to add perssions to read."
  type        = string
  default     = null
}

variable "lambda_graph_generator_arn" {
  description = "ARN of the Lambda function to add perssions to invoke."
  type        = string
  default     = null
}

variable "aws_region" {
  type        = string
  description = "AWS region of the SSM parameters to grant access to them in the TaskExecutionRole."
  validation {
    condition     = can(index(["eu-north-1", "ap-south-1", "eu-west-3",
                              "eu-west-2", "eu-west-1", "ap-northeast-2",
                              "ap-northeast-1", "sa-east-1", "ca-central-1",
                              "ap-southeast-1", "ap-southeast-2", "eu-central-1",
                              "us-east-1", "us-east-2", "us-west-1", "us-west-2"], var.aws_region))
    error_message = "The aws_region value must be a valid AWS region (eu-north-1, us-west-2, etc.)."
  }
}


#variables for SSM parameter:

variable "ssm_service_param_path" {
  description = "The path of SSM parameters related to the ECS service."
  type        = string
  default     = "/"
  validation {
    condition     = substr(var.ssm_service_param_path, 0, 1) == "/"
    error_message = "The ssm_param_name value must start with `/`."
  }
}

variable "ssm_general_param_path" {
  description = "The path of SSM parameters common for the all ECS services."
  type        = string
  default     = "/"
  validation {
    condition     = substr(var.ssm_general_param_path, 0, 1) == "/"
    error_message = "The ssm_param_name value must start with `/`."
  }
}

variable "ssm_param_value" {
  description = "The value for the database_url SSM parameter."
  type        = string
  default     = null
}

variable "kms_alias" {
  description = "The KMS key alias ARN for encrypting a SecureString."
  type        = string
  default     = null
}

variable "kms_key" {
  description = "The KMS key ARN for encrypting a SecureString."
  type        = string
  default     = null
}

variable "access_to_sns" {
  description = "Whether to attach AmazonSNSFullAccess policy to TaskExecution Role."
  type        = bool
  default     = false
}