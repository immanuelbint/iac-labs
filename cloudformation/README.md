# CloudFormation (AWS only)

Infrastructure as a Code, works with almost all of AWS resources, can be repeated across Regions & Accounts

## Template Component
- AWSTemplateFormatVersion: identifies the capabilities of the template "2010-09-09".
- Description: comment about template .
- Resources: your AWS resources declared in the template.
- Parameters: the dynamic inputs for template.
- Mappings: the static variables for template.
- Outputs: references to what has been created.
- Conditionals: list of conditions to perform resource creation.

## Template Helper
- References
- Functions