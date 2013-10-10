% This class merges the functionality of exam.cls with the look
% and feel of tufte-handout. The former (exam.cls) has all the 
% functionality we need. The latter provides the layout that is 
% oh-so-pretty. 

% Code has therefore been shamelessly copied from tufte-common.sty 

\NeedsTeXFormat{LaTeX2e} 
\ProvidesClass{tufte-exam}[2011/09/01 Exam class with Tufte layout] 

% Load class before requiring 'tufte-common' (via tufte-tweaks) . 
% Otherwise, you will get multiple \undefined errors !! 
%
% This is not a happy situation. Ideally, the code should be more 
% robust than this. But the only way to make code more robust would
% to re-write / re-organize substantional portions of 'exam.cls' 
% and / or 'tufte-common.sty'. Not a battle I want fight now

\LoadClassWithOptions{exam} 
\RequirePackage{tufte-tweaks}
\RequirePackage{amsmath}  
\RequirePackage{amssymb} 
\RequirePackage{pst-barcode} 
\RequirePackage{tikz} 
\RequirePackage{auto-pst-pdf} 
\RequirePackage{siunitx}
\RequirePackage{fig4tex}
\RequirePackage{g-trig}
\RequirePackage{g-seq}
\RequirePackage{g-calculator}
\RequirePackage{g-2d}
\RequirePackage{g-comb}
\RequirePackage{etoolbox}
\RequirePackage{xcolor}
\RequirePackage{calculator}
\RequirePackage{g-calculus}
\RequirePackage{g-vector}

\providecommand{\ud}{\, \mathrm{d}}
%\renewcommand{\solutiontitle}{\noindent{\sc{Solution\\}}\enspace}

%% Commands to control layout

\providecommand{\mcq}{\stretch{1}} 
\providecommand{\halfpage}{\stretch{2}}
\providecommand{\fullpage}{\stretch{4}} 

\providecommand\baseQR{}
\providecommand\setbaseQR[1]{
  \renewcommand\baseQR{#1}
}

\providecommand\embedQR[1][0pt] {
  \ifprintanswers
  \else
    \ifcancelspace
    \else
      \begin{marginfigure}
        \psbarcode[transy=#1,transx=0.4\marginparwidth]{\baseQR-\thepage-\thequestion}{eclevel=Q width=0.7 height=0.7}{qrcode} 
      \end{marginfigure}
    \fi

  \fi
}

\newcommand\nextpg{
  \ifprintanswers
  \else
    % Write the QR Code in the top-right and bottom-left corners 
    \begin{textblock}{600}(410,12)
      % {\LARGE\fontfamily{ccr}\selectfont{\StrLeft{#2}{4} -\StrMid{#2}{5}{8} -\StrRight{#2}{3}}}
      {\LARGE\fontfamily{ccr}\selectfont{\baseQR-\thepage}}
    \end{textblock}
    \begin{textblock}{600}(20,770)
      % {\LARGE\fontfamily{ccr}\selectfont{\StrLeft{#2}{4} -\StrMid{#2}{5}{8} -\StrRight{#2}{3}}}
      {\LARGE\fontfamily{ccr}\selectfont{\baseQR-\thepage}}
    \end{textblock}

    \ifcancelspace
    \else\newpage\fi
  \fi
}

