# Factorio LUT tool

A tool which applies LUT colours to images.


# Requires:
* [Python 3.7+](https://www.python.org/downloads/)
* [Pillow](https://pillow.readthedocs.io/en/stable/)

# Usage methods:

## A. Process all images in the folder automatically
Simple to use method with little control over what the script does.
* Copy the LUT.py and _LUTs folder into your mod directory.
* Launch LUT.py directly, without any arguments.
* ALL found *.PNG images in this directory and subdirectories will be converted.
* Outputs can be found in _OUTPUT folder.
    
## B. Process only selected images
Launch LUT.py with arguments, the most controllable way to use the script.
* -i specifies the input file
* -o specifies where to output
* -l specifies the LUT used (from _LUTs folder)      
* -if -i is not used, all files in the current directory and all subdirectories (except _LUTs and _OUTPUT) will be searched
* -if -o is not used, the output file path will automatically be the same as the input, under the _OUTPUT folder
* -if -l is not used, lut-day.png is used  
    
Example command:
* LUT.py -i nuclear_furnace.png -o _OUTPUT/nuclear_furnace.png -l lut-day.png
    
## C. Drag&drop a file on LUT.py
Simple to use method for individual files.
* lut-day will be applied to the file.

You can find which images got which LUT applied in the vanilla_instructions directory.
