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

\RequirePackage{savesym}
\LoadClassWithOptions{exam} 
\savesymbol{fullwidth}
\savesymbol{lhead}
\savesymbol{chead}
\savesymbol{rhead}
\savesymbol{lfoot}
\savesymbol{cfoot}
\savesymbol{rfoot}
\RequirePackage{tufte-tweaks}
\restoresymbol{TFT}{fullwidth}
\restoresymbol{TFT}{lhead}
\restoresymbol{TFT}{chead}
\restoresymbol{TFT}{rhead}
\restoresymbol{TFT}{lfoot}
\restoresymbol{TFT}{cfoot}
\restoresymbol{TFT}{rfoot}

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
\RequirePackage{xstring}
\RequirePackage{calculator}
\RequirePackage{g-calculus}
\RequirePackage{g-vector}

%% Counters 
\newcounter{currSubpart}
\newcounter{numQuestions}
% 'numQR' tracks 'numpage' counter exactly. But we have it still to
% keep things clean & distinct
\newcounter{numQR} 

%% Booleans 
\newbool{bottomLeftQR}
\booltrue{bottomLeftQR}

\newbool{bottomLeftTaken}
\boolfalse{bottomLeftTaken}

%% Macros that define space left for explanations 
\providecommand{\mcq}{\stretch{1}} 
\providecommand{\halfpage}{\stretch{2}}
\providecommand{\fullpage}{\stretch{4}} 

%% A special environment for rendering any large tables and graphs 
%% that may be part of the question. Ideally, render any such data AFTER 
%% the solution text and take care of \thepage as it (\thepage) controls QR code insertion

\newcounter{pgregister}
\newenvironment{attachment}{
  \setcounter{pgregister}{\thepage}
  \nextpg
  \setbaseQR{Attachment}
  \embedQR
}{
  \nextpg
  \setcounter{page}{\thepgregister}
}

%% Environment Re-definitions
\newenvironment{explanation}[1][\halfpage]{\begin{solution}[#1]}{\end{solution}}

%% Utility macros
\providecommand{\ud}{\, \mathrm{d}}
\providecommand\drawAxes[5] {
  % Wrapper call for \figdrawaxes - with some pre-settings and re-settings
  \figset arrowhead(fillmode=yes,length=6,angle=15)
  \figset general(color=0.7)
  \figdrawaxes #1(#2,#3,#4,#5)
  \figreset{general}
}

%% Macros related to QR codes
\providecommand\baseQR{}
\providecommand\setbaseQR[1]{
  \renewcommand\baseQR{#1}
}

\providecommand\embedQR[1][0pt] {
  \ifprintanswers
  \else
    \ifcancelspace
    \else
      \ifbool{bottomLeftQR}{
        \ifbool{bottomLeftTaken}{}{
          \fancyfoot[L]{
            \psbarcode[transx=-30pt, transy=-15pt]
            {\baseQR}{eclevel=Q width=0.7 height=0.7}{qrcode} 
          }
          \setbool{bottomLeftTaken}{true}
        }
      }{ % no QR in bottom-left => insert QR right there
        \begin{marginfigure}[#1]
          \psbarcode[transx=0.4\marginparwidth]{\baseQR}{eclevel=Q width=0.7 height=0.7}{qrcode} 
        \end{marginfigure}
      }

      \ifdefempty\baseQR{}{
        % Write the QR Code in the top-right and bottom-left corners 
        \fancyhead[R]{\Large\fontfamily{cmss}\selectfont{\baseQR}}
        \fancyfoot[R]{\Large\fontfamily{cmss}\selectfont{\baseQR}}
      }
    \fi % if cancelspace
  \fi % ifprintanswers 

  \setbool{bottomLeftQR}{false}
}

% [Deprecated]  
\providecommand\currQR{}
\providecommand{\insertQR}[2][0pt]{}

%% Ref: http://tex.stackexchange.com/questions/80154/get-n-th-element-of-a-list-with-etoolbox-or-not

\providecommand\storePerPageQR[1]{
  \stepcounter{numQR}
  \expandafter\def\csname qr\thenumQR\endcsname{#1}
}

%% Macros pertaining to question versioning
\providecommand\storeVersions[1]{
  \stepcounter{numQuestions}
  \expandafter\def\csname version\thenumQuestions\endcsname{#1}
}

%% Macros to set student or teacher name 
% Usage: \setAuthor[1,2,3]{Ms. Slokham}{ERT/0/1,ERS/0/3, ... , RTE/1/2/3}
\providecommand{\setAuthor}[3][]{
  \notblank{#1}{
    \forcsvlist\storeVersions{#1}
    \setcounter{rolldice}{\csname version1\endcsname} % set version for Q1
  }{}
  \fancyhead[LO,LE]{\Large\fontfamily{cmss}\selectfont{\uppercase{#2}}}
  \notblank{#3}{
    \setcounter{numQR}{0}
    \forcsvlist\storePerPageQR{#3}
  }{\setbaseQR{Preview}}
}

\providecommand{\DocAuthor}[2][]{\setAuthor[#1]{#2}{}}

\providecommand\documentTitle{}
\providecommand\setDocumentTitle[1]{
  \renewcommand\documentTitle{#1}
}
\providecommand\School[1]{\setDocumentTitle{#1}}


%% [Callbacks]

\providecommand\pageBreaks{}
\providecommand\setPageBreaks[1]{
  \renewcommand\pageBreaks{}
  \forcsvlist{\listadd\pageBreaks}{#1}
}

\providecommand\versionTriggers{}
\providecommand\setVersionTriggers[1]{
  \renewcommand\versionTriggers{}
  \forcsvlist{\listadd\versionTriggers}{#1}
}

\newcommand\nextpg{
  \ifcancelspace
  \else
    \booltrue{bottomLeftQR}
    \boolfalse{bottomLeftTaken}
    \newpage
  \fi
}

\BeforeBeginEnvironment{explanation}{
  \embedQR
  \setcounter{equation}{0}
}


\AfterEndEnvironment{explanation}{
  \setbool{bottomLeftQR}{false}
  \xifinlist{\thecurrSubpart}\pageBreaks{\nextpg}{}
  \xifinlist{\thecurrSubpart}\versionTriggers{
    \ADD{\value{question}}{1}\nq
    \ifcsmacro{version\nq}{
      \setcounter{rolldice}{\csname version\nq\endcsname }
    }
    % \setcounter{rolldice}{\csname version\j\endcsname}
  }{}

  \stepcounter{currSubpart} % Move onto next subpart 
}

\BeforeBeginEnvironment{questions}{
  \setcounter{page}{1}
  \setcounter{currSubpart}{0} % the breaks returned by Rails are 0-indexed
  \fancyhead[C]{\Large\fontfamily{cmss}\selectfont\documentTitle}
  \fancyfoot[C]{\Large\fontfamily{cmss}\selectfont{\copyright\, www.gradians.com}}
  \marksnotpoints
  %\pagestyle{fancy}
  \renewcommand\headrulewidth{0.4pt}
  \setbaseQR{\csname qr\thepage\endcsname}
}

\AfterEndEnvironment{questions}{
  \setcounter{numQuestions}{0}
  \ifprintanswers
  \else
    \ifnumodd{\thepage}{
      \nextpg
      \mbox{}
      \setbaseQR{0}
      \embedQR
      \fancyhead[C]{\Large\fontfamily{cmss}\selectfont{For Rough Work Only}}
      \fancyfoot[C]{\Large\fontfamily{cmss}\selectfont{Will not be graded}}
    }{}
    \nextpg 
  \fi % \ifprintanswers
}


\BeforeBeginEnvironment{marginfigure}{
  % This next bit of code is really needed when making worksheets only. 
  % If the marginfigure is rendered within \ifprintanswers, then this code will NOT be triggered
  % However, if a margin figure is unconditionally rendered, then this code 
  % should trigger 
  \setbool{bottomLeftQR}{true}
}
