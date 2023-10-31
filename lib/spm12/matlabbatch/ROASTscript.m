cd ('C:\Users\jlee\Documents\MATLAB\roastV2.7.1');
roast(('N:\Documents\Jenny\Roast_files\TestImage_1mm.nii'),{'CP5',1,'F1',-1}, 'simulationTag', 'CP5F1_1mA', 'resampling', 'on', 'zeroPadding', 40, 'elecsize', [17 2]);
