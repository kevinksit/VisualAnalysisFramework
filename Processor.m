classdef Processor < handle
	properties
		raw_data double % this is the main data matrix
		initial_dimensions
		stimulus_data

		on_resp double % the following three are the sorted responses
		base_resp double
		blank_resp double 

		data double % response
	end
	methods
		function obj = Processor(raw_data)
			if isa(raw_data, 'struct')
				obj.raw_data = raw_data.DFF;
				obj.raw_data = permute(obj.raw_data, [2, 1]);
			elseif isa(raw_data, 'double')
				obj.raw_data = raw_data;
				obj.raw_data = permute(obj.raw_data, [3, 1, 2]); % Make sure to remember to "unpermute" this later
			else
				error('Your data type does not comply, are you using data from our lab?')
			end
			% Reshape the data so we're always dealing with the same dimensional data (thanks Tyler)
			obj.initial_dimensions = size(obj.raw_data);
			obj.raw_data = reshape(obj.raw_data, size(obj.raw_data, 1), []);			
			obj.getStimulusData();
		end

		function getStimulusData();
			disp('Choose your stimulus data file')
			[fn, pn] = uigetfile('.mat');
			obj.stimulus_data = importdata([pn, fn]);
		end

		function sortData(obj)
			% extract stimulus data variables
			[blank_frames, base_frames, on_frames, relax_frames, presentation_frames, repeat_frames] = obj.getEpochFrames();

			% Main sorting loop
			for r = 1:obj.stimulus_data.n_repeats
				curr_frame = (r - 1) * repeat_frames;
				obj.blank_resp(r, :, :) = obj.raw_data(curr_frame : curr_frame + blank_frames - 1);
				for p = 1:obj.stimulus_data.n_presentations
					curr_frame = (r - 1) * repeat_frames + (p - 1) * presentation_frames;
					obj.base_resp(r, p ,:, :) = obj.raw_data(curr_frame : curr_frame + base_frames - 1);
					obj.on_resp(r, p, :, :) = obj.raw_data(curr_frame + base_frames :...
					 curr_frame + base_frames + on_frames + relax_frames - 1);
				end
			end

			% It's going to be one or the other, never do both
			if blank_frames ~= 0
				obj.subtractBlank();
			elseif base_frames ~= 0
				obj.subtractBaseline();
			else
				obj.data = obj.on_resp; % No subtraction or normalization at all
			end

			~~~~obj.data = reshape(obj.data, obj.initial_dimensions);
			% What do we wan to do with obj.data at this point? repermute it?
		end

		function subtractBlank(obj)
			for r = 1:obj.stimulus_data.n_repeats
				blank = squeeze(mean(obj.blank_resp(r, :, :), 2));
				obj.data(r, :, :, :) = obj.raw_data(r, :, :, :) - blank;
			end
		end

		function subtractBaseline(obj)
			for r = 1:obj.stimulus_data.n_repeats
				for p = 1:obj.stimulus_data.n_presentations
					baseline = squeeze(mean(obj.baseline_resp(r, p, :, :, 2)));
					obj.data(r, p, :, :) = obj.raw_data(r, p, :, :) - baseline;
				end
			end
		end

		function getEpochFrames(obj, fs)
			if nargin < 2 || isempty(fs)
				fs = 10;
			end

			blank_frames = obj.stimulus_data.blank_time * fs;
			base_frames = obj.stimulus_data.base_time * fs;
			on_frames = obj.stimulus_data.on_time * fs;
			relax_frames = obj.stimulus_data.relax_time * fs;

			% Calculating additional parameters
			presentation_frames = base_frames + on_frames + relax_frames;
			repeat_frames = presentation_frames .* obj.stimulus_data.n_presentations;
		end
	end
