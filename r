Path Pattern Validation

Implement regex patterns or rules in the data.yaml file that validate the structure of exception paths
Reject patterns that appear to be artificially created (e.g., overly specific paths, unusual nesting)
Require exceptions to match known, pre-approved resource naming conventions


# Define allowed path patterns
opa_skip_validation:
  allowed_patterns:
    # Pattern structure: <module>.<resource_type>.<resource_name>[.<attribute>]
    - regex: "^module\\.([a-z0-9_-]+)\\.module\\.([a-z0-9_-]+)\\.aws_[a-z_]+\\[\\d+\\]\\..*$"
      description: "Nested module resources with numeric index"
    
    - regex: "^module\\.([a-z0-9_-]+)\\.aws_[a-z_]+\\.([a-z0-9_-]+)(\\..*)?$"
      description: "Direct module resources"
    
    - regex: "^aws_[a-z_]+\\.([a-z0-9_-]+)(\\..*)?$"
      description: "Root-level AWS resources"
  
  blocked_patterns:
    # Patterns that look suspicious
    - regex: ".*\\.exception.*"
      reason: "Contains 'exception' in path - likely artificial"
    
    - regex: "^.*\\.(skip|bypass|ignore)_.*"
      reason: "Suspicious naming convention"
    
    - regex: "^.{200,}$"
      reason: "Path too long - likely constructed to be unique"
