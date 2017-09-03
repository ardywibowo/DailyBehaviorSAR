% This function arranges data as separate .csv files for every user

function structureData()

% Get data table from files 
activitiesData		= readtable('Data/activities_sample.csv');
foodEntriesData		= readtable('Data/food_entries_sample.csv');
sleepsData				= readtable('Data/sleeps_sample.csv');
weighinsData			= readtable('Data/weighins_sample.csv');
workoutsData			= readtable('Data/workouts_sample.csv');
rawData = {activitiesData; foodEntriesData; sleepsData; weighinsData; workoutsData};

% Create data files for each user ID
userInformation		= readtable('Data/users_sample.csv');
userId = userInformation.mfp_user_id;

for j = 1 : size(userId)
	% Find entries for user j
	currentUserId = userId(j);
	currentUserData = userData(rawData, currentUserId);
	
	% Combine all entries for user
	combinedData = currentUserData{1};
	for k = 2 : numel(currentUserData)
		combinedData.Properties.VariableNames{3} = 'date';
		combinedData = outerjoin(combinedData, currentUserData{k}, 'LeftKeys', {'date', 'mmf_user_id', 'mfp_user_id'}, ...
			'RightKeys', {dateFieldTitle(k), 'mmf_user_id', 'mfp_user_id'}, 'MergeKeys', true);
	end
	combinedData.Properties.VariableNames{3} = 'record_date';
	combinedData.Var11 = [];
	
	writetable(combinedData, strcat('Users/', num2str(userId(j)), '.csv'));
end

end

function currentUserData = userData(rawData, currentUserId)
% Finds the data related to a single user in rawData

% Get indexes for the user whose id == currentUserId
currentUserDataIndexes = cell(size(rawData));
for k = 1 : numel(rawData)
	currentUserDataIndexes{k} = rawData{k}.mfp_user_id == currentUserId;
end

% Get the data from the indexes found
currentUserData = cell(size(rawData));
for k = 1 : numel(rawData)
	currentUserData{k} = rawData{k}(currentUserDataIndexes{k}, :);
end
	
end

function dateTitle = dateFieldTitle(n)
% Returns the title of the date field on each data set. 
% Dependent on the order that the files are loaded. 

switch n
	case 1
		dateTitle = 'activity_date';
	case 2
		dateTitle = 'entry_date';
	case 3 
		dateTitle = 'sleep_date';
	case 4
		dateTitle = 'weigh_date';
	case 5
		dateTitle = 'workout_date';
	otherwise
		dateTitle = '';
end

end