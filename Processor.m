classdef Processor < handle
	properties
		raw_data double % this is the main data matrix
		initial_dimensions
		stimulus_data
		twop_flag = false;

		on_resp double % the following three are the sorted responses
		pre_resp double
		post_resp double 

		data double % response
	end
	methods
		function obj = Processor(raw_data)
			if isa(raw_data, 'struct')
				obj.raw_data = raw_data.DFF;
				obj.raw_data = permute(obj.raw_data, [3, 1, 2]); % adding a dimension to 2p data
				obj.twop_flag = true;
			elseif isa(raw_data, 'single')
				obj.raw_data = raw_data;
			else
				error('Your data type does not comply, are you using data from our lab?')
			end

			obj.getStimulusData();
		end

		function getStimulusData(obj);
			disp('Choose your stimulus data file')
			[fn, pn] = uigetfile('.mat');
			obj.stimulus_data = importdata([pn, fn]);
		end

		function sortData(obj)
			disp('Sorting data...')
			% extract stimulus data variables
			[pre_frames, on_frames, post_frames, presentation_frames, repeat_frames] = obj.getEpochFrames();
			% Main sorting loop
			for r = 1:obj.stimulus_data.n_repeats
				disp(r)
				for p = 1:obj.stimulus_data.n_presentations
					curr_frame = (r - 1) * repeat_frames + (p - 1) * presentation_frames;
					obj.pre_resp(:, :, :, p, r) = obj.raw_data(:, :, curr_frame + 1: curr_frame + pre_frames);
					obj.on_resp(:, :, :, p, r) = obj.raw_data(:, :, curr_frame + pre_frames + 1:...
						curr_frame + pre_frames + on_frames );
					obj.post_resp(:, :, :, p, r) = obj.raw_data(:, :, curr_frame + pre_frames + on_frames + 1:...
						curr_frame + pre_frames + on_frames + post_frames ); 
				end
			end

			% It's going to be one or the other, never do both
			if pre_frames ~= 0
				obj.subtractBaseline();
			else
				obj.data = obj.on_resp; % No subtraction or normalization at all
			end

			if obj.twop_flag
				obj.data = squeeze(obj.data);
			end
		end

		function subtractBaseline(obj)
			disp('Subtracting baseline...')
			for r = 1:obj.stimulus_data.n_repeats
				for p = 1:obj.stimulus_data.n_presentations
					baseline = squeeze(mean(obj.pre_resp(:, :, :, p, r), 3));
					obj.data(:, :, :, p, r) = obj.on_resp(:, :, :, p, r) - baseline;
				end
			end
		end

		function [pre_frames, on_frames, post_frames, presentation_frames, repeat_frames] = getEpochFrames(obj, fs)
			if nargin < 2 || isempty(fs)
				fs = 10;
			end

			pre_frames = obj.stimulus_data.pre_time * fs;
			on_frames = obj.stimulus_data.on_time * fs;
			post_frames = obj.stimulus_data.post_time * fs;

			% Calculating additional parameters
			presentation_frames = pre_frames + on_frames + post_frames;
			repeat_frames = presentation_frames .* obj.stimulus_data.n_presentations;
		end
	end
end