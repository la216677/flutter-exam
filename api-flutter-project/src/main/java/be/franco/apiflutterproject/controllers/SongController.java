package be.franco.apiflutterproject.controllers;

import be.franco.apiflutterproject.service.SongService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;

@RestController
@RequestMapping("/storageSong")
public class SongController {

    @Autowired
    private SongService service;

    @PostMapping("/uploadSong")
    public ResponseEntity<Long> uploadSong(@RequestParam("file") MultipartFile file) throws IOException {
        return new ResponseEntity<>(service.uploadSong(file), HttpStatus.OK);
    }

    @GetMapping(value = "/downloadSong/{fileName}", produces = "audio/mpeg")
    public @ResponseBody byte[] downloadSong(@PathVariable String fileName) {
        return service.downloadSong(fileName);
    }

    // associate song with photo
    @PostMapping("/associateSongWithPhoto/{songId}/{photoId}")
    public ResponseEntity<String> associateSongWithPhoto(@PathVariable Long songId, @PathVariable Long photoId){
        service.associateSongWithPhoto(songId, photoId);
        return new ResponseEntity<>("Song associated with photo", HttpStatus.OK);
    }
}
