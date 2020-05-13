clear all;
close all;
clc;

disp("Exercise 1");
a = 1:100;
b = (mod(a,4)==0) | (mod(a,7)==0);
res = a(b).';
res

disp("Exercise 2");
rng('shuffle');
n = randi([10, 20]);
a = rand(1, n);
a(end-2:end) = 0;
[max, ind] = max(a);
a
res = "Max = " + max + " ; Index = " + ind

disp("Exercise 3");
x = -20:0.01:20;
a = 5;
y = Sinc(x, a);
f1 = figure;
plot(x, y);

disp("Exercise 4");
k = [1; 2; 3; 4];
klog(k);

disp("Exercise 5");
A = [1, 2.2, 1, 0, 0];
B = [-4, -1.75, 0, 1, 0];
C = [1, 0, 1, 2, 5];
[x1, x2] = solveQuadEq(A, B, C);

for i = 1:length(x1) 
    str = "A = " + num2str(A(i)) + "   B = " + num2str(B(i)) + "   C = " + num2str(C(i));
    if (isnan(x1(i)))
        str = str + "   No roots";
    elseif (~isreal(x1(i)))
        str = str + "   No real roots";
    else
        str = str + "   x1 = " + num2str(x1(i));
        if (isreal(x2(i)) & ~isnan(x2(i))) 
            str = str + "   x2 = " + num2str(x2(i));
        end
    end;
    disp(str);
end;

disp("Exercise 6");
tree = {{1, {2}}, {3, {4, 5}, 6, 7}};
tree{2}{2}{2} = {8, 9};

% Functions

function res = Sinc(x, a)
if ~(exist('a'))
    a = 0;
end
res = sin(x - a) ./ (x - a);
res(isnan(res)) = 1;
end

function klog(k)
    x = 0.01:0.01:100;
    y = k * log(x);
    
    f2 = figure;
    plot(x, y);
    title('y = k*ln(x)');
    xlabel('x');
    ylabel('y');
    grid on;
    lgd = cell(1, size(k, 1));
    for i=1:size(k, 1);
        lgd{i} = ['k = ' num2str(i)];
    end
    legend(lgd, 'Location', 'southeast');
    axis([0.01, 2, -5, 2]);
    
    set(gca, 'FontSize', 12);
    print(gcf, 'fig2', '-dtiff', '-r300');
end

function [x1, x2] = solveQuadEq(A, B, C)
    if (size(A) == size(B)) & (size(A) == size(C))
        D = sqrt(B.*B - 4 * A.*C);
        x1 = (-B - D) ./ (2 * A);
        x2 = (-B + D) ./ (2 * A);
        A0 = (A == 0 & B ~= 0);
        x1(A0) = -C(A0) ./ B(A0);
    else
        disp("dimensions of A, B, C should be equal");
        x1 = NaN;
        x2 = NaN;
    end;
end
