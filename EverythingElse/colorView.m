%%% MAKING AN IMAGE FROM THE DATA!

% Initialize Image
image = zeros(length(inclination),length(semimajorAxis),3);

for a = 1:length(semimajorAxis)
    for b = 1:length(inclination)
        index = (b-1)*length(semimajorAxis) + a;
        color = satellite(index).Graphics.Attributes.Color;

        if color == 255
            image(b,a,:) = [255 0 0];
        elseif color == 65280
            image(b,a,:) = [0 255 0];
        elseif color == 65535
            image(b,a,:) = [255 255 0];
        elseif color == 16776960
            image(b,a,:) = [0 255 255];
        elseif color == 16777215
            image(b,a,:) = [255 255 255];
        else
            disp('How did this happen...')
        end
        %{
            colorDecimal = 16776960;        % Cyan
            colorDecimal = 65280;           % Green
            colorDecimal = 65535;           % Yellow
            colorDecimal = 255;             % Red
            colorDecimal = 16777215;        % White
        %}

    end
end

image = imresize(image,'Method', 'nearest', 'OutputSize', [500 1000]);

imshow(image, 'XData', [semimajorAxis,semimajorAxis(end) + semimajorAxis(2)-semimajorAxis(1)] - 6378,...
    'YData', [inclination, inclination(end) + inclination(2)-inclination(1)]);
axis on
ylabel('Inclination')
xlabel('SemiMajorAxis')
yticks(inclination(1):4:inclination(end) + inclination(2) - inclination(1))
yticklabels(num2cell(inclination(1):4:inclination(end) + inclination(2) - inclination(1)))
xticks([semimajorAxis,semimajorAxis(end) + semimajorAxis(2) - semimajorAxis(1)] - 6378)


