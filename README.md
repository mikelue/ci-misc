This repository is used for common-scripts for CI environment

[maven](maven/)

Scripts for maven building
- `show-dumpfiles.sh` - Dumps files generated by [Sureifre plugin](http://maven.apache.org/surefire/maven-surefire-plugin/) and [Failsafe plugin](http://maven.apache.org/surefire/maven-failsafe-plugin/)
- `extract-code-coverage-jmockit.sed`([GNU sed](https://www.gnu.org/software/sed/)) - Extracts total value of code coverage generated by [JMockit](http://jmockit.github.io/tutorial/CodeCoverage.html)

[aws](maven/)

Scripts for AWS

`login-aws-ecr.sh` - [Logs-in](https://docs.aws.amazon.com/AmazonECR/latest/userguide/ECR_AWSCLI.html) to [AWS ECR](https://docs.aws.amazon.com/AmazonECR/latest/userguide/what-is-ecr.html) by environments:
- `AWS_ACCESS_ID`
- `AWS_SECRET_ACCESS_KEY` - should be put in **secret value keeper** of CI services
- `AWS_REGION`