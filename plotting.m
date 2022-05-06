%%% PLOTTING

figure

imshow(imresize(color, [5*(length(inclination)) 100*(length(semimajorAxis))], 'nearest'))
hold on
axis('on', 'image');

xstring = ['(from ', num2str(semimajorAxis(1)), ' to ', num2str(semimajorAxis(end)), ')'];
ystring = ['(from ', num2str(inclination(1)), ' to ', num2str(inclination(end)), ')'];
xlabel(['Semimajor Axis ', xstring])
ylabel(['Angle of Inclination ', ystring])

%{
yticks(20*(0:length(inclination)-1))
yticklabels(num2cell(inclination(1:4:end-1)))

xticks(100*(0:length(semimajorAxis)-1))
xticklabels(num2cell(semimajorAxis(1:end-1)))
%}