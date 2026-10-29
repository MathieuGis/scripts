# Help-site deployment

Fleet and Sky tools are grouped by application and named by deployment environment. The alternative FieldTest version remains separate under sky/fieldtest-alternate/; it has not been assumed redundant.

Import-HelpSiteSettings.ps1 loads the optional source path configuration. See [configuration](../../config/README.md). Deployment destination hosts and commands are retained from the originals. These scripts remove and replace remote content and require the original server access. Validate settings before running them; repository validation never runs deployments.
