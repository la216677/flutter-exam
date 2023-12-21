package be.franco.apiflutterproject.controllers;

import be.franco.apiflutterproject.entity.Photo;
import be.franco.apiflutterproject.service.PhotoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;

@RestController
@RequestMapping("/photo")
public class PhotoController {

    @Autowired
    private PhotoService photoService;

    @PostMapping("/upload")
    public String uploadPhoto(@RequestParam("file") MultipartFile file) throws IOException {
        Photo photo = new Photo();
        photo.setPath(file.getOriginalFilename());
        return photoService.uploadPhoto(file);
    }

    @GetMapping("/{path}")
    public Photo getPhoto(@PathVariable("path") String path) {
        return photoService.getPhoto(path);
    }

    @GetMapping("/all")
    public Photo[] getAllPhotos() {
        return photoService.getAllPhotos();
    }

    @DeleteMapping("/{path}")
    public void deletePhoto(@PathVariable("path") String path) {
        photoService.deletePhoto(path);
    }

    @GetMapping("/id/{id}")
    public Photo getPhotoById(@PathVariable("id") Long id) {
        return photoService.getPhotoById(id);
    }
    @PutMapping("/update")
    public Photo updatePhoto(@RequestBody Photo photo) {
        return photoService.updatePhoto(photo);
    }

}
