package be.franco.apiflutterproject.controllers;

import be.franco.apiflutterproject.entity.Song;
import be.franco.apiflutterproject.service.SongService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

@RestController
@RequestMapping("/song")
public class SongController {

    @Autowired
    private SongService songService;

    @PostMapping("/upload")
    public String uploadSong(@RequestParam("file") MultipartFile file) throws IOException {
        Song song = new Song();
        song.setPath(file.getOriginalFilename());
        return songService.uploadSong(file);
    }

    @GetMapping("/{path}")
    public Song getSong(@PathVariable("path") String path) {
        return songService.getSong(path);
    }

    @GetMapping("/stream/{path}")
    public ResponseEntity<Resource> streamSong(@PathVariable String path) {
        File file = new File("src/main/resources/static/songs/" + path);
        HttpHeaders headers = new HttpHeaders();
        headers.add(HttpHeaders.CONTENT_DISPOSITION, "inline;filename=\"" + path + "\"");
        headers.setCacheControl("must-revalidate, post-check=0, pre-check=0");
        Path pathOk = Paths.get(file.getAbsolutePath());
        ByteArrayResource resource = null;
        try {
            resource = new ByteArrayResource(Files.readAllBytes(pathOk));
        } catch (IOException e) {
            e.printStackTrace();
        }
        return ResponseEntity.ok()
                .headers(headers)
                .contentLength(file.length())
                .contentType(MediaType.parseMediaType("audio/mpeg"))
                .body(resource);
    }


    @GetMapping("/all")
    public Song[] getAllSongs() {
        return songService.getAllSongs();
    }

    @DeleteMapping("/{path}")
    public void deleteSong(@PathVariable("path") String path) {
        songService.deleteSong(path);
    }

}
