require(ez)
require(xtable)

print.ezANOVA <- function(ezanova,file="",label=NULL,caption="",win=""){
  columnspan <- function(string) paste("\\multicolumn{10}{l}{",string,"}\\\\")
  if(caption == ""){
    caption <- paste("ANOVA",sep="")
    if(win != "")
      caption <- paste(caption, " for the ",win," window",sep="")
  }
  
  caption <- paste("\n\\caption{",caption,"}",sep="")
  
  label <- paste("\n\\label{",label,"}",sep="")
  
  cat("\\begin{table}[htb]",caption,label,"\n\\begin{center}\n\\small",file=file)
  cat("\n\\begin{tabular}{rlrrrrrrlr}",file=file,append=TRUE)
  cat("\n\\toprule",file=file,append=TRUE)
  cat(columnspan("\\textbf{ANOVA:}"),file=file,append=TRUE)
  print(xtable(ezanova$ANOVA, row.names="Effect"),
        floating=FALSE,hline.after=NULL,
        add.to.row=list(pos=list(-1,0, nrow(ezanova$ANOVA)), command=c('\\toprule\n','\\midrule\n', '\\bottomrule\n')),
        only.contents=TRUE,file=file,append=TRUE,math.style.negative=T)
  
  if(!is.null(ezanova$`Mauchly's Test for Sphericity`)){
    cat("\n\\midrule\n",file=file,append=TRUE)
    cat(columnspan("\\textbf{Mauchly's Test for Sphericity:}"),file=file,append=TRUE)
    
    print(xtable(ezanova$`Mauchly's Test for Sphericity`, row.names="Effect"),
          floating=FALSE,hline.after=NULL,
          add.to.row=list(pos=list(-1,0, nrow(ezanova$`Mauchly's Test for Sphericity`)), command=c('\\toprule\n','\\midrule\n', '\\bottomrule\n')),
          only.contents=TRUE,file=file,append=TRUE,math.style.negative=T)
    cat("\n\\midrule\n",file=file,append=TRUE)
    
    cat(columnspan("\\textbf{Sphericity Corrections:}"),file=file,append=TRUE)
    print(xtable(ezanova$`Mauchly's Test for Sphericity`, row.names="Effect"),
          floating=FALSE,hline.after=NULL,
          add.to.row=list(pos=list(-1,0, nrow(ezanova$`Sphericity Corrections`)), command=c('\\toprule\n','\\midrule\n', '\\bottomrule\n')),
          only.contents=TRUE,file=file,append=TRUE,math.style.negative=T)
  }
  
  cat("\n\\end{tabular}\n\\end{center}\n\\end{table}",file=file,append=TRUE)
}