package be.franco.apiflutterproject.controllers;

import be.franco.apiflutterproject.entity.Photo;
import be.franco.apiflutterproject.service.ImageService;
import be.franco.apiflutterproject.service.SongService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;

@RestController
@RequestMapping("/image")
public class ImageController {

    @Autowired
    private ImageService service;

    @Autowired
    private SongService songService;

    @PostMapping
    public ResponseEntity<?> uploadImage(@RequestParam("image") MultipartFile file) throws IOException, IOException {
        String uploadImage = service.uploadImage(file);
        return ResponseEntity.status(HttpStatus.OK)
                .body(uploadImage);
    }

    @GetMapping("/{fileName}")
    public ResponseEntity<?> downloadImage(@PathVariable String fileName){
        byte[] imageData=service.downloadImage(fileName);
        return ResponseEntity.status(HttpStatus.OK)
                .contentType(MediaType.valueOf("image/png"))
                .body(imageData);
    }
    // Get by id
    @GetMapping("search/{id}")
    public ResponseEntity<?> getById(@PathVariable Long id){
        byte[] imageData=service.downloadImage(id);
        return ResponseEntity.status(HttpStatus.OK)
                .contentType(MediaType.valueOf("image/png"))
                .body(imageData);
    }

    // Get all
    @GetMapping("search/all")
    public ResponseEntity<?> getAll(){
        return ResponseEntity.status(HttpStatus.OK)
                .body(service.getAll());
    }

    // Get all ids
    @GetMapping("/allIds")
    public ResponseEntity<?> getAllIds(){
        return ResponseEntity.status(HttpStatus.OK)
                .body(service.getAllIds());
    }

    @GetMapping("/get/model/{id}")
    public ResponseEntity<?> getModelById(@PathVariable Long id){
        return ResponseEntity.status(HttpStatus.OK)
                .body(service.getById(id));
    }

    // Delete by id
    @DeleteMapping("/delete/{id}")
    public ResponseEntity<?> deleteById(@PathVariable Long id){
        // get photo with id and delete song if exists
        Photo photo = service.getById(id);
        service.deleteById(id);
        if(photo.getSong() != null){
            songService.deleteSong(photo.getSong().getId());
        }
        return ResponseEntity.status(HttpStatus.OK)
                .body("Deleted");
    }
}
