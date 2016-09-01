function ignore_on = cassis_check_ignorelist(ignorelist, item)
ignore_on = false;
for nignore = 1:length(ignorelist)
    if( strcmp(ignorelist(nignore), item) )
        ignore_on = true;
        break;
    end
end
end