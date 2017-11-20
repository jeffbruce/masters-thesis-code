function individual_report(name, num)

[lf hf phone avgerror ovrerror] = analyze_loc_laser(name,num,0);
[mhn, mhnthresh, mhnstd] = analyze_mhnoise(name,num);
[timbre, timthresh, timstd] = analyze_timbre_noise(name,num);

plot_condition()
plot_speakers()
plot_mistuned()
plot_timbre()

    function plot_condition()
        subplot(2,2,1);
        bar(ovrerror);
        set(gca,'XTickLabel',{'low', 'high', 'phone'});
        set(gca,'YLim',[0 45]);
        title('Error For Each Condition');
        xlabel('Condition');
        ylabel('Error (degrees)');
    end

    function plot_speakers()
        subplot(2,2,2);
        bar(mean(avgerror,2));
        set(gca,'XTickLabel',{'0','15','30','45','60','75','90'});
        set(gca,'YLim',[0 45]);
        title('Error For Each Speaker');
        xlabel('Speaker Position (degrees)');
        ylabel('Error (degrees)'); 
    end

    function plot_mistuned()
        subplot(2,2,3);
        bar((mhnthresh-1)*100);
        set(gca,'XTickLabel',{'200Hz','600Hz'});
        set(gca,'YLim',[0 30]);
        title('Mistuned Harmonic Thresholds by Tone Frequency');
        xlabel('Frequency (Hz)');
        ylabel('% Mistuning'); 
    end

    function plot_timbre()
        subplot(2,2,4);
        bar(timthresh*100);
        set(gca,'XTickLabel',{'350Hz','1050Hz'});
        set(gca,'YLim',[0 100]);
        title('Intensity Thresholds by Harmonic Frequency');
        xlabel('Frequency (Hz)');
        ylabel('% Discriminable Intensity'); 
    end

end