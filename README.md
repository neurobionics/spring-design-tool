# spring-design-tool
a software tool that facilitates the design of lightweight torsion springs

<p float="left">
  <img src="Design Tool Snip.png" width="500" />
  <img src="spring GIF.gif" width="290" /> 
</p>

## INSTALLATION:
If you have a Matlab license, the quickest and easiest way to proceed is to install the Design Tool as a custom Matlab App (APPS>Install App). If you do not have access to a Matlab license and you do have access to a PC, then open the .exe file and it will install the Design Tool as a desktop application.

## USE:
Hover over labels and/or data fields for explanations of each input. For 'Optional' arguments, leaving the input as 0 allows the design tool to automatically calculate appropriate values. When inputs are set, click 'Create Spring' to generate your custom design. For best performance, enter a 'Run Time' of 15-30 seconds. If the design looks satisfactory, select your output 'File Type' and 'Units' and click 'Download Design'. The 'File Type' selection will depend on the CAD software you intend to use (e.g. Solidworks uses '.txt' while Fusion360 and Onshape use '.csv').

## CREATE SOLID MODEL:
The tool outputs xyz-coordinates of your custom spring design with several different curve options, so consult README_profile_descriptions (which appears in the output folder) for detailed explanations. To create a 3D solid model, import the appropriate curves into the CAD software of your choice and use the profiles to create geometry that can be extruded to your designed spring thickness. The process for importing the curves varies across CAD platforms, but tutorials can typically found by searching 'CAD_SOFTWARE_NAME curve through xyz points' in an internet browser.

## EXAMPLES:
If you are new to designing springs, or unsure of appropriate stiffness/deflection ranges, below are some examples from the literature of spring radius, thickness, stiffness and deflection:

dos Santos et al. '15: 62.5mm 6mm 150Nm/rad 5.73deg
Carpino et al. '12: 42.5mm 3mm 92Nm/rad 4.76deg
Georgiev et al. '17: 74mm 9.5mm 600Nm/rad 20deg
Tsagarakis et al. '09: 35mm 10mm 153Nm/rad 10deg
Lagoda et al. '10: 37.5mm 15mm 353Nm/rad 16.23deg
Wang et al. '13: 41.5mm 10.5mm 800Nm/rad 7.16deg

