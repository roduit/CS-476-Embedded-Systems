<div align="center">
<img src="./logo-epfl.png" alt="Example Image" width="192" height="108">
</div>

<div align="center">
Ecole Polytechnique Fédérale de Lausanne
</div> 
<div align="center">
CS-476 Embedded System Design
</div> 

# Sobel Motion Detection

## Table of Contents

- [Abstract](#abstract)
- [Repository Structure](#project-structure)
- [Technical Informations](#technical-informations)
- [Contributors](#contributors)

## Abstract
The purpose of the project is to develop a system capable of detecting motion using combination of hardware (coded in Verilog) and Software (programmed in C). This project was conducted on a gecko4education board. 

## Project Structure

The repository is constructed as follow:
```
.
├── README.md
├── documents
│   ├── cs476_presentation.pdf
│   └── cs_476_project_report.pdf
├── python_tb
│   └── sobel_calc.py
└── versions
    ├── final_result
    │   ├── README.md
    │   ├── modules
    │   ├── programms
    │   └── systems
    └── software
        ├── README.md
        ├── modules
        ├── programms
        └── systems
```
The folder `versions` contains the software implementation as well as the final result implementation.

The code can be found under `./submission/versions/final_result/programms/camera/src/camera.c`

and `./submission/versions/software/programms/camera/src/camera.c`.

## Technical Information
A PDF is provided in `./documents/cs476_report.pdf` and contains all the technical information as well as theoretical aspects. Please refer to this document for related questions.

## Contributors
This repository has been elaborated by Filippo Quadri and Vincent Roduit, two electrical engineering master students at EPFL during the 2024 Spring Semester.
