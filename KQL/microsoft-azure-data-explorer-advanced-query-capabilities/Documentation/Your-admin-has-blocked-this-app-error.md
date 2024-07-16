# Correcting the Installation Error

When installing the Kusto desktop application, you may get the error message:

_Your administrator has blocked this application because it potentially poses a security risk to your computer._

This error happens because the ClickOnce trust prompt is disabled.

To fix, use **RegEdit**, and go to:

\HKEY_LOCAL_MACHINE\SOFTWARE\MICROSOFT\.NETFramework\Security\TrustManager\PromptingLevel

Change the state of the required setting to Enabled.
