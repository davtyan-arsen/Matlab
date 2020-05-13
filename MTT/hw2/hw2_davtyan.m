clear all;
close all;
clc;

load strings;

disp("Exercise 1");
[a, p] = alphabet_probabilities(X);
a
p

disp("Exercise 3");
H_cond_val = conditional_value_entropy(X, Y, 'b')

disp("Exercise 6");

H_max = log2(length(a));

H_x = entropy(X)
H_y = entropy(Y)
R_x = 1 - H_x / H_max
R_y = 1 - H_y / H_max
H_x_y = conditional_entropy(X, Y)
H_y_x = conditional_entropy(Y, X)
I_x_y = joint_information(X, Y)
I_y_x = joint_information(Y, X)
H_xy = joint_entropy(X, Y)

disp("Checking equalities and inequalities");
err = 1e-10;
c1 = H_x_y <= H_x & H_x <= H_max;
c2 = H_y_x <= H_y & H_y <= H_max;
c3 = I_x_y == I_y_x;
c4 = (H_xy - H_x - H_y_x) < err;
c5 = H_xy - (H_y + H_x_y) < err;
c6 = H_xy - (H_x + H_y - I_x_y) < err;

if c1&c2&c3&c4&c5&c6
    disp("All is good");
else
    disp("Not good");
end;

function [alphabet, probs] = alphabet_probabilities(X)
    alphabet = unique(X);
    numOccur = @(c) (length(X(X == c)));
    probs = arrayfun(numOccur, alphabet) / length(X);
end

function H = entropy(X)
    [~, probs] = alphabet_probabilities(X);
    H = - sum(probs .* log2(probs));
end

function H_cond_val = conditional_value_entropy(X, Y, y)
    [~, probs] = alphabet_probabilities(X(Y == y));
    H_cond_val = - sum(probs .* log2(probs));
end

function H_cond = conditional_entropy(X, Y)
    [alphabet, probs] = alphabet_probabilities(Y);
    H_cond = 0;
    for i = 1:length(alphabet)
        H_cond = H_cond + probs(i) * conditional_value_entropy(X, Y, alphabet(i));
    end;
end

function I_joint = joint_information(X, Y)
    I_joint = entropy(X) - conditional_entropy(X, Y);
end

function H_joint = joint_entropy(X, Y)
    Z = string([X; Y].');
    H_joint = entropy(Z);
end