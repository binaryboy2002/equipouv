%%% Programa para Falla de Formacion de Polvo y suciedad

clc
clear all
close all


%%% Parametros del data-sheet SW 250 MONO

ns = 60; %Numero de celdas en el panel conectadas en serie
isc = 2.5; %Corriente de cortocircuito en STC
impp = 2.9; %Corriente en MPP (STC)
vmpp = 31.1; % Voltaje en MPP (STC)
pmpp = 250; %Potencia en MPP (STC)
voc = 33; %Voltaje en circuito abierto en el panel
kv= -0.30;  %Coeficiente de temperatura Voc
ki= 0.004;  %Coeficiente de temperatura Isc
Rs = 0.486561; %Resistencia en serie 
Rsh = 5.91277e+08; %Resistencia en Paralelo 
Vt = 0.012944; %Voltaje termico 
Io=(isc-(voc-isc*Rs)/Rsh)*exp(-voc/(ns*Vt)); %Corriente de saturacion del Diodo 
Iph=Io*exp(voc/(ns*Vt))+voc/Rsh; %Corriente fotogenerada
Gstc=1000;  %Irradiaza estandar 
Tstc=25; %Temperatura estandar



load ('Datos.mat')

Temperatura = Datos(:,1);
Voltajereal1 = Datos(:,2);
Corrientereal1 = Datos(:,3);
Irradianza = Datos(:,4);
Tiempo = Datos(1:1000,5);
n = 1000;
T = Temperatura;
G = Irradianza;

%%% EN BASE A LA TEMPERATURA %%%
vocT=voc+kv*(T-Tstc); % Voc(T)
iscT=isc*(1+ki*(T-Tstc)/100); % Isc(T)
IoT=(iscT-(vocT-iscT*Rs)./Rsh).*exp(-vocT/(ns*Vt));% Io(T)
IphT=IoT.*exp(vocT/(ns*Vt))+vocT/Rsh; % Iph(T)

%%% EN BASE A LA TEMPERATURA E IRRADIANZA %%%

IscGT=iscT.*G/Gstc; % Isc(G,T)
IphGT=IphT.*G/Gstc; % Iph(G,T)

%%% Calculo de Voc(G,T) mediante Newton-Raphson

for i=1:1:n
    syms vocgt
    vocG = voc;
    vocgt = log((IphGT(i) * Rsh - vocgt)/(IoT(i) * Rsh))*ns*Vt - vocgt;
    vocGTDif = diff(vocgt);
    vocGTx = inline(vocgt)';
    VocGTDifx = inline(vocGTDif);
    
    error2 = 1;
%     itera = 0;
    tolerancia = 1e-3;
     while error2 > tolerancia
         vocgNEW = vocG - vocGTx(vocG)/VocGTDifx(vocG);
         error2 = (abs(vocG-vocgNEW)/vocgNEW)*100;
         vocG = vocgNEW;
%          itera = itera + 1;
     end
     vocGT(i) = vocgNEW;
end

% Vo=0:0.1:vocGT;
% DIM=length(Vo);

for i=1:1:n 
  Iv=3;
  syms I
  gra=IphGT(i)-IoT(i)*(exp((vocGT(i)+I*Rs)/(ns*Vt)-1))-(vocGT(i)+I*Rs)/Rsh-I;
  gr=diff(gra);
  grax=inline(gra)';
  grx=inline(gr);
  iter3=0;
  error3=1;
  tolerancia = 1e-3;
    while error3>tolerancia

        Inew=Iv-grax(Iv)/grx(Iv);
        error3=abs(Iv-Inew)/Inew*100;
        Iv=Inew;
        iter3=iter3+1;
    end
    corrientes(i)=Inew;
end

I = corrientes;
V = vocGT;

xi=Corrientereal1-6.3*I.';
lamda=0.2;
k=3;
sigma=std(xi);
mo=mean(xi);
yi0=mo;

n=length(xi);
for i=1:n
    
    yi(i)= lamda*xi(i)+(1-lamda)*yi0;
    yi0=yi(i);
    
    LCS(i)= mo + (k*sigma)*(sqrt((lamda*(1-(1-lamda)^(2*i)))/(2-lamda)));
    LC=mo;
    LCI(i)= mo - (k*sigma)*(sqrt((lamda*(1-(1-lamda)^(2*i)))/(2-lamda)));
    
    LCSV= LCS(i)*ones(1,n);
    LCIV= LCI(i)*ones(1,n);
    LCV= mo*ones(1,n);
end
%%% se detrmina si el sistema esta trabajando 
mqttClient = mqttclient("tcp://broker.emqx.io",ClientID="myClient",Port=1883);
topicToWrite = "equipouv/javierjesusluis/valor2";

 M = csvread('Datos.csv',0,2);
n=length(M(:,1));
while (true)
    Iact = csvread('Datos.csv',0,2,[0,2,n,2]);
    
    if (Iact >LCS) | (Iact <LCI)
     
    msg = "1";
    write(mqttClient, topicToWrite, msg);
    else

    msg = "0";
    write(mqttClient, topicToWrite, msg);

    end
    n=n+1;
end

% mqttClient = mqttclient("tcp://broker.emqx.io",ClientID="myClient",Port=1883);
% 
% topicToWrite = "equipouv/javierjesusluis/valor2";
% msg = "1";
% write(mqttClient, topicToWrite, msg);



