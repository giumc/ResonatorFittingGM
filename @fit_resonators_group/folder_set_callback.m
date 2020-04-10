function folder_set_callback(~,~,obj)
    if isempty(obj.folder)
        return
    else
        folders=obj.folder;
        for i=1:length(folders)
            files=obj.find_files(folders(i));
            for k=1:length(files)
                fullpath=strcat(files(k).folder,filesep,files(k).name);
                obj.resonators(i,k)=resonator('file',fullpath);
                obj.resonators(i,k).tag=files(k).name;
            end
        end
    end

end