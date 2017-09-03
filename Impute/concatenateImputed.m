normalized = [];
for i = 1:27
	newMat = load(strcat('PACE Original/', num2str(i), '.mat'));
	newMat = newMat.imputedData;
	normalized = vertcat(normalized, newMat);
end

user = normalized(1,:);
j = 1;
for i = 1:size(normalized,1)-1
	if normalized(i+1,2) == normalized(i,2) 
		user = vertcat(user, normalized(i+1, :));
	else
		save(strcat('PACE Imputed Data/', num2str(j), '.mat'), 'user');
		user = normalized(i+1,:);
		j = j + 1;
	end
	
	if i == size(normalized, 1)-1
		save(strcat('PACE Imputed Data/', num2str(j), '.mat'), 'user');
		user = normalized(i+1,:);
		j = j + 1;
	end
end