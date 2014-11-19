% printanswers        cancelspace         implies           QR-code?
% ------------        -----------         --------          --------
%  false               false        worksheet / exam         yes
%  false               true         abridged worksheet       no
%  true                false             quiz                no
%  true                true            non-sense             -
% 

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
\LoadClass[justified,a4paper]{exam} 
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
\RequirePackage{venndiagram}
\RequirePackage{newfile} % for creating .codex from within codex environment 
\RequirePackage{tabularx}

%% Counters 
\newcounter{currSubpart}
\newcounter{numQuestions}
\newcounter{questionPg} % counter for pages that have questions
\newcounter{worksheetPg} % counter for all pages in the worksheet - incl. those with attachments

%% Booleans 
\newbool{qrcInMargin}
\boolfalse{qrcInMargin}

\newbool{normalflow}
\booltrue{normalflow}

\newbool{invault}
\boolfalse{invault}

\providecommand\compilevault{\setbool{invault}{true}}
\providecommand\nocompilevault{\setbool{invault}{false}}

% trim and notrim.jpg for mobile phones
\newbool{trimjpg}
\boolfalse{trimjpg}
\providecommand\zealouscrop{\setbool{trimjpg}{true}}
\providecommand\nozealouscrop{\setbool{trimjpg}{false}}

%% If .. else 

%% Macros that define space left for explanations 
\providecommand{\mcq}{\stretch{1}} 
\providecommand{\halfpage}{\stretch{2}}
\providecommand{\fullpage}{\stretch{4}} 

\newenvironment{calcaid}{\vspace{0.5cm}\color{blue}\Large}{}

%% A special environment for rendering any large tables and graphs 
%% that may be part of the question. Ideally, render any such data AFTER 
%% the solution text and take care of \thepage as it (\thepage) controls QR code insertion

\newenvironment{attachment}{
  \setbool{normalflow}{false}
  \setbool{qrcInMargin}{false}
  \pagebreak
}{
  \nextpg 
  \setbool{normalflow}{true}
}

%% Environment Definitions and Re-definitions  
\newenvironment{explanation}[1][\halfpage]{\begin{solution}[#1]}{\end{solution}}

\newenvironment{codex}{
  \ifbool{invault}{
    \fancyfoot{}
    \newpage
    \newoutputstream{cdx}
    \openoutputfile{codex.cdx}{cdx}
    \closeoutputstream{cdx}
  }{}
  \fontfamily{cmss}\selectfont\LARGE
}{}

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

\providecommand\marginQR[1][0pt] {
  \ifbool{qrcInMargin}{
    \begin{marginfigure}[#1]
      \psbarcode[transx=0.4\marginparwidth]{\baseQR}{eclevel=Q width=0.7 height=0.7}{qrcode} 
    \end{marginfigure}
  }{}
}

\providecommand\bottomQR[1][\baseQR] {
  % Write the QR Code in the top-right and bottom-left corners 
  \fancyfoot[L]{
    \psbarcode[transx=-30pt, transy=-15pt]{#1}{eclevel=Q width=0.7 height=0.7}{qrcode} 
  }
  \fancyhead[R]{\Large\fontfamily{cmss}\selectfont{#1}}
  \fancyfoot[R]{\Large\fontfamily{cmss}\selectfont{$\thequestionPg\,\vert\,\thepage$}}
}

% [Deprecated]  
\providecommand\currQR{}
\providecommand{\insertQR}[2][0pt]{}

%% Ref: http://tex.stackexchange.com/questions/80154/get-n-th-element-of-a-list-with-etoolbox-or-not

\providecommand\storePerPageQR[1]{
  \expandafter\def\csname qr\thequestionPg\endcsname{#1}
  \stepcounter{questionPg}
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
    \setcounter{questionPg}{1}
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
    \ifprintanswers
    \else
      \ifbool{normalflow}{\bottomQR}{\bottomQR[Attachment]}
      \pagebreak
      \setbool{qrcInMargin}{false}
      \stepcounter{worksheetPg}
      \ifbool{normalflow}{\stepcounter{questionPg}}{}
    \fi % ifprintanswers
  \fi % ifcancelspace
}

\BeforeBeginEnvironment{explanation}{
  \ifprintanswers
  \else % worksheet or exam
    \ifcancelspace % abridged worksheet 
    \else
      \setbaseQR{\csname qr\thequestionPg\endcsname}
      \marginQR
    \fi
  \fi
  \setcounter{equation}{0}
}

\AfterEndEnvironment{explanation}{
  \setbool{qrcInMargin}{true}
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
  %\setcounter{page}{1}
  \setcounter{questionPg}{1}
  \setcounter{worksheetPg}{1}
  \setcounter{currSubpart}{0} % the breaks returned by Rails are 0-indexed
  \setbool{normalflow}{true}

  \fancyhead[C]{\Large\fontfamily{cmss}\selectfont{\documentTitle}}

  \ifbool{invault}{
    \qformat{}
    \fontfamily{cmss}\selectfont\LARGE
  }{
    \noqformat % suppress question numbering in vault/ else default behaviour
    \fontfamily{cmss}\selectfont\Large
  } 
  \ifbool{trimjpg}{}{\fancyfoot[C]{\copyright\, www.gradians.com}}

  \marksnotpoints
  %\pagestyle{fancy}
  \renewcommand\headrulewidth{0.4pt}
  \setbaseQR{\csname qr\thequestionPg\endcsname}
  \renewcommand\solutiontitle{}
  \SolutionEmphasis{\normalsize}
  \shadedsolutions
}


\AfterEndEnvironment{questions}{
  \setcounter{numQuestions}{0}
  \ifprintanswers
  \else
    \ifcancelspace % abridged worksheet
    \else % full worksheet or exam
      \ifnumodd{\theworksheetPg}{ % has to be \theworksheetPg only as it tracks the *absolute* # of pages
        \nextpg
        \mbox{}
        \bottomQR[0]

        \ifbool{invault}{}{
          \ifcancelspace % => takehome worksheet compilation
          \else % => in-class worksheet compilation
            \fancyhead[C]{\Large\fontfamily{cmss}\selectfont{For Rough Work Only}}
            \fancyfoot[C]{\Large\fontfamily{cmss}\selectfont{Will not be graded}}
          \fi
        }
      }{} % ifnumodd
    \fi
    \nextpg 
  \fi % \ifprintanswers
}


\BeforeBeginEnvironment{marginfigure}{
  % This next bit of code is really needed when making worksheets only. 
  % If the marginfigure is rendered within \ifprintanswers, then this code will NOT be triggered
  % However, if a margin figure is unconditionally rendered, then this code 
  % should trigger 
  \setbool{qrcInMargin}{false}
}

%%% Rendering polynomials
\newbool{isFirstPolyTerm}
\newcommand{\poly@pwr}{}
\newcommand{\startpoly}{\setbool{isFirstPolyTerm}{true}}

\newcommand\WRITEPOLYTERM[3][x]{ 
  % #1 = independent variable, #2 = coefficient, #3 = raised to power, 
  \ABSVALUE{#2}\kf
  \ABSVALUE{#3}\pw
  \ifnumcomp{\pw}{=}{1}{\renewcommand{\poly@pwr}{}}{\renewcommand{\poly@pwr}{\pw}}
%
  \ifnumcomp{#3}{>}{0}{ % x raised to positive power 
    \ifnumcomp\kf{=}{1}{ % +1x or -1x 
      \ifnumcomp{#2}{<}{0}{-#1^{\poly@pwr}}{
        \ifbool{isFirstPolyTerm}{#1^{\poly@pwr}}{+#1^{\poly@pwr}}
      }
    }{ % coefficient != +1 or -1 
      \ifnumcomp{#2}{<}{0}{#2 #1^{\poly@pwr}}{
        \ifbool{isFirstPolyTerm}{#2 #1^{\poly@pwr}}{+#2 #1^{\poly@pwr}}
      }
    }
  }{
    \ifnumcomp{#3}{<}{0}{ % Example: x^{-2}
      \ifnumcomp{#2}{<}{0}{-\dfrac\kf{#1^{\poly@pwr}}}{
        \ifbool{isFirstPolyTerm}{\dfrac\kf{#1^{\poly@pwr}}}{+\dfrac\kf{#1^{\poly@pwr}}}
      }
    }{ % Example: x^0 => just the coefficient
      \ifnumcomp{#2}{<}{0}{#2}{
        \ifbool{isFirstPolyTerm}{#2}{+#2}
      }
    }
  }
  \setbool{isFirstPolyTerm}{false}
}
