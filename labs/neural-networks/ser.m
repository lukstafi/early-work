% normalizacja danych
cheese_normal = cheese;% na razie nie ma
  for cecha = 1:4
    cecha_min = min(cheese(:,cecha));
    cecha_max = max(cheese(:,cecha));
    mianownik = cecha_max-cecha_min;
    for i = 1:30
	cheese_normal(i,cecha) = (cheese(i,cecha)-cecha_min)/mianownik;
    end
  end

figure(1) 


%//dobre opcje 1:  ite: 20, f: linear, 16:25

options = foptions
options(14) = 10

errorL = zeros(10,1);%wektor pusty 7 zer, Learning set
errorT = zeros(10,1);%test ste
%opcje programu

ile_neuronow = zeros(30,1)
for i=1:30 ile_neuronow(i) = i*3; end;
ile_cech = 3;
wielkosc_probki = 10
algorytm = 'scg';
funkcja = 'logistic';

hold off;
errorT_min = zeros(30,1);
errorT_max = zeros(30,1);
errorT_med = zeros(30,1);

errorL_min = zeros(30,1);
errorL_max = zeros(30,1);
errorL_med = zeros(30,1);

learning_set = cheese_normal(1:wielkosc_probki,2:4);
learning_set_target   = cheese_normal(1:wielkosc_probki,1); 

test_set = cheese_normal(16:25,2:4);
test_set_target = cheese_normal(16:25,1);
