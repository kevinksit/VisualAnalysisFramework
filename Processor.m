classdef Processor < handle
	properties
		raw_data_fn % this is the main data matrix
		stimulus_data
		twop_flag = false;

		on_resp double % the following three are the sorted responses
		pre_resp double
		post_resp double 

		data double % response
	end
	methods
		function obj = Processor(raw_data_fn)
			obj.raw_data_fn = raw_data_fn;
			obj.getStimulusData();
		end

		function getStimulusData(obj);
			disp('Choose your stimulus data file')
			[fn, pn] = uigetfile('.mat');
			obj.stimulus_data = importdata([pn, fn]);
		end

		function checkDataLength(obj, data_length, repeat_frames)
			expected_length = repeat_frames * obj.stimulus_data.n_repeats;
			if data_length < expected_length
				disp('Issues with timing led to fewer frames than expected, removing last repeat...')
				obj.stimulus_data.n_repeats = obj.stimulus_data.n_repeats - 1;
			end
		end

		function sortData(obj)
			disp('Sorting data...')
			% Get the data
			raw_data = importdata(obj.raw_data_fn);

			raw_data = obj.typeConvert(raw_data);

			% Extract stimulus data parameters
			[pre_frames, on_frames, post_frames, presentation_frames, repeat_frames] = obj.getEpochFrames();
			
			obj.checkDataLength(length(raw_data), repeat_frames);

			% Preallocate arrays
			pre_resp = zeros(size(raw_data, 1), size(raw_data, 2), pre_frames, obj.stimulus_data.n_presentations, obj.stimulus_data.n_repeats);

			on_resp = zeros(size(raw_data, 1), size(raw_data, 2), on_frames + post_frames, obj.stimulus_data.n_presentations, obj.stimulus_data.n_repeats);

			post_resp = zeros(size(raw_data, 1), size(raw_data, 2), post_frames, obj.stimulus_data.n_presentations, obj.stimulus_data.n_repeats);

			% Sort

			for r = 1:obj.stimulus_data.n_repeats
				for p = 1:obj.stimulus_data.n_presentations
					curr_frame = (r - 1) * repeat_frames + (p - 1) * presentation_frames;
					pre_resp(:, :, :, p, r) = raw_data(:, :, curr_frame + 1: curr_frame + pre_frames);
					on_resp(:, :, :, p, r) = raw_data(:, :, curr_frame + pre_frames + 1:...
						curr_frame + pre_frames + on_frames + post_frames);
					post_resp(:, :, :, p, r) = raw_data(:, :, curr_frame + pre_frames + on_frames + 1:...
						curr_frame + pre_frames + on_frames + post_frames ); 

					if pre_frames ~= 0
						baseline = squeeze(mean(pre_resp(:, :, :, p, r), 3));
						data(:, :, :, p, r) = on_resp(:, :, :, p, r) - baseline;
					else
						data(:, :, :, p, r) = on_resp(:, :, :, p, r);
					end
				end
			end

			% Assign variables to properties
			obj.pre_resp = pre_resp;
			obj.on_resp = on_resp;
			obj.post_resp = post_resp;

			if obj.twop_flag
				obj.data = squeeze(data);
			else
				obj.data = data;
			end
		end

		function out = typeConvert(obj, raw_data)
			switch class(raw_data)
			case 'struct'
				raw_data = raw_data.DFF;
				out = permute(raw_data, [3, 1, 2]); % adding a dimension to 2p data
				obj.twop_flag = true;
			case 'single'
				out = raw_data;
			otherwise
				error('Your data type does not comply, are you using data from our lab?')
			end
		end

		function out = subtractBaseline(obj)
			disp('Subtracting baseline...')
			out = zeros(size(obj.on_resp));
			pre_resp = obj.pre_resp;
			on_resp = obj.on_resp;
			for r = 1:obj.stimulus_data.n_repeats
				for p = 1:obj.stimulus_data.n_presentations
					baseline = squeeze(mean(pre_resp(:, :, :, p, r), 3));
					out(:, :, :, p, r) = on_resp(:, :, :, p, r) - baseline;
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

		function out = getProcessedData(obj)
			out = obj.data;
		end

		function out = getStimdat(obj)
			out = obj.stimulus_data;
		end
	end
end