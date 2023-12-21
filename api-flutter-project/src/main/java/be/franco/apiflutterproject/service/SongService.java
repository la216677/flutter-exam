package be.franco.apiflutterproject.service;

import be.franco.apiflutterproject.entity.Song;
import be.franco.apiflutterproject.respository.SongRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

@Service
public class SongService {

    @Autowired
    private SongRepository songRepository;

    public String uploadSong(MultipartFile song) throws IOException {
        String uploadDir = "src/main/resources/static/songs/";

        File uploadDirectory = new File(uploadDir);
        if (!uploadDirectory.exists()) {
            uploadDirectory.mkdir();
        }

        Path uploadPath = Path.of(uploadDir + song.getOriginalFilename());

        // Vérifiez si le fichier existe déjà
        if (Files.exists(uploadPath)) {
            System.out.println("La chanson existe déjà");
            return null;
        }

        song.transferTo(uploadPath);

        Song songOk = new Song();
        songOk.setPath(song.getOriginalFilename());

        Song savedSong = songRepository.save(songOk);
        return savedSong.getPath();
    }


    public Song getSong(String path) {
        return songRepository.findByPath(path);
    }

    public Song[] getAllSongs() {
        return songRepository.findAll().toArray(new Song[0]);
    }

    public void deleteSong(String path) {
        Song song = songRepository.findByPath(path);
        File file = new File("src/main/resources/static/songs/" + song.getPath());
        file.delete();
        songRepository.delete(song);
    }

    public void deleteSongById(Long id) {
        Song song = songRepository.findById(id).get();
        File file = new File("src/main/resources/static/songs/" + song.getPath());
        file.delete();
        songRepository.delete(song);
    }
}
