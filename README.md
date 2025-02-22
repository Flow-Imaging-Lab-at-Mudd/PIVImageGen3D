# 3D Extension of PIV Image Generator

PIV Image Generator is a tool that generates synthetic Particle Imaging Velocimetry (PIV) images with the purpose of validating and benchmarking PIV and Optical Flow methods in tracer based imaging for fluid mechanics.

This tool intends to be a reference library for reuse by anyone interested in evaluating said algorithms for velocimetry in fluid mechanics applications. 
The image generator can be used to create a reference central database for reporting and comparing benchmark results.

The image generator is easily extensible for other flow types.

The 3D extension includes multi-camera array simulation using the Machine Vision Toolbox, 3D illumination (thicker light sheet), and the ability to add bodies and occlusions to the particle field.


**Licensed under the GNU Public License v2**

## Prerequisites
MATLAB is required to run this tool. Required MATLAB Toolboxes:
- Symbolic Math Toolbox
- Phased Array System Toolbox
- Statistics and Machine Learning Toolbox
- Partial Differential Equation Toolbox (for geometry files)

Camera functions rely on the Machine Vision Toolbox by Peter Corke (https://github.com/petercorke/machinevision-toolbox-matlab)

## Acknowledgment

This code extends PIV Image Generator to multicamera imaging. The official source repository for the original PIV Image Generator is located in the CoreRasurae Gitlab repository and can be cloned using the
following command.

```bash

git clone https://git.qoto.org/CoreRasurae/piv-image-generator.git
```

