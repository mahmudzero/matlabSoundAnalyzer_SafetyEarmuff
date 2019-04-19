%create a sound recording object with sampling frequency 44100, 24bits
%quantization, and mono(1) audio
%stero would be (2)
sound_recorder = audiorecorder(44100, 24, 1);

%vector to store recorded data in after each sample
intermediate_sound_vector = [];

%vector of last 15 samples, currently unused
continuous_sound_vector = [];

%sample counter
%used to limit time application is run
number_of_samples = 0;

%number of times threshhold seen
threshold_hit = 0;


%if while 1, would run forever
while number_of_samples < 50
	%increment number of samples
	number_of_samples = number_of_samples + 1;
	
	%record data for 0.01s
	recordblocking(sound_recorder, 0.01);
	
	%convert sound to array of floats
	intermediate_sound_vector = getaudiodata(sound_recorder);
	
	%get #of samples
	length_of_sound_vector = length(intermediate_sound_vector);
	%get frequency axis
	frequency_samples = (44100/length_of_sound_vector)*[0: (1): length_of_sound_vector - 1];
	%get FFT of sound
	fspectrum_sound_vector = abs(fft(intermediate_sound_vector));
	%plot spectrum of sound
	plot(frequency_samples, reshape(fspectrum_sound_vector, [1, 441]));
	
	
	if(fspectrum_sound_vector(201) > 0.2)
		threshold_hit = threshold_hit + 1;
		webwrite("https://safety-earmuff.herokuapp.com/send-mail", "status=found");
		disp("Writing to server");
		disp("Found");
	else
		threshold_hit = 0;
	end
	
	%if signal is found and seen for "0.03s", we alert the users,
	%time is actually longer than 0.03s due to all data being analyzed
	%on a single thread
	%{
	if(threshhold_hit == 1)
		%make an HTTP post request to a server
		webwrite("https://safety-earmuff.herokuapp.com/send-mail", "status=found");
		disp("Writing to server");
	end
	%}
end
