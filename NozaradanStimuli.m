function [output,t] = NozaradanStimuli(varargin)


% example 1: output = NozaradanStimuli({'samplerate',44110},{'duration',33},{'modulationdepth',.25},{'accent',true},{'standard',true})
% 
% example 2: output = NozaradanStimuli()
%
% example 3: output = NozaradanStimuli({'accent',true})
% Usage:
% sampleRate = sampling rate of the stimuli. 44100 hz is a good choice
% duration = the duration in the seconds of the stimuli.  33 is a good
% chocie
% modulationDepath = self explanatory. Nozaradan used .25
% frequency = stimulus frequency. Nozaradan used 333.33
% beat = beat frequncy. Nozaradan used 2.4 [currently not used]
% accent = 'true' means accent every second beat
% standard = 'true' means don't add sound interruption
%
% defaults reproduce the Nozaradan et al (2015) stimuli
% the sound can then be played using 'sound' e.g.,
% sound(output,44100);
% or even
% sound(NozaradanStimuli,44100)

out = varargin;
varnames = cellfun(@(x) x{1},out,'UniformOutput',false);
varvalues = cellfun(@(x) x{2},out,'UniformOutput',false);
if nargin >= 1
    parameters = cell2struct(varvalues,varnames,2);
else
    parameters = struct;
end



if ~ismember('samplerate',varnames)
    parameters.samplerate = 44100; % hz
end

if ~ismember('duration',varnames)
    parameters.duration = 33; % seonds
end

if ~ismember('frequency',varnames)
    parameters.frequency = 333.33; % hz
end

if ~ismember('beat',varnames)
    parameters.beat = 'not used';
end

if ~ismember('accent',varnames)
    parameters.accent = 0;
end

if ~ismember('modulationdepth',varnames)
    parameters.modulationdepth = .25;
end

parameters



wave = sin(0:(2*pi)/((parameters.samplerate/parameters.frequency)):(((2*pi)*parameters.frequency)*parameters.duration));

t = 0:(parameters.duration/parameters.samplerate)/parameters.duration:parameters.duration;


%hannwindow = makehannwindow(modulationDepth);

if parameters.accent
    hannwindow = [makehannwindow(parameters.modulationdepth*.50,.50,parameters.samplerate);...
        makehannwindow(parameters.modulationdepth,1,parameters.samplerate)];
else
    hannwindow = [makehannwindow(parameters.modulationdepth,1,parameters.samplerate);...
        makehannwindow(parameters.modulationdepth,1,parameters.samplerate)];
end

        
tempo = 2.4;
amMod = repmat(hannwindow,ceil(2.4* parameters.duration)/2,1);

amMod = amMod(1:length(wave))';

output = wave .* amMod;

function hannwindow = makehannwindow(modulationdepth,maxMod,samplerate)
risetime = .012; % 12 ms
windowduration = round((samplerate * risetime)*2);

minMod = modulationdepth;
hannwindow1 = hann(windowduration,'symmetric')*(maxMod-minMod)+minMod;
[~,i1] = max(hannwindow1);

falltime = .404; % 404 ms
windowduration = round((samplerate * falltime)*2);

hannwindow2 = hann(windowduration,'symmetric')*(maxMod-minMod)+minMod;
[~,i2] = max(hannwindow2);

hannwindow = [hannwindow1(1:i1);hannwindow2(i2:end)];