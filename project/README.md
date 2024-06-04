<div align="center">
<img src="../resources/logo-epfl.png" alt="Example Image" width="192" height="108">
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
│   └── cs476_presentation.pptx
├── python_tb
│   └── sobel_calc.py
├── steps
│   ├── dma_alone
│   ├── sobel_ci
│   └── software
├── tree.txt
└── virtual_prototype
    ├── README.md
    ├── modules
    ├── programms
    └── systems
```
The folder `steps` contains all the steps that lead to the final solutions. They can be compiled to see the intermediate results. These steps are:
1. software
2. sobel_ci
3. dma_alone
4. dma_4conv

The folder `virtual_prototype` contains the final result. Again, it can be used to see the result.

## Technical Information
A PDF is provided in `./documents/cs476_report.pdf` and contains all the technical information as well as theoretical aspects. Please refer to this document for related questions.

## Contributors
This repository has been elaborated by Filippo Quadri and Vincent Roduit, two electrical engineering master students at EPFL during the 2024 Spring Semester.
