package be.franco.apiflutterproject.controllers;

import be.franco.apiflutterproject.entity.User;
import be.franco.apiflutterproject.respository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/user")
public class UserController {

    @Autowired
    private UserRepository userRepository;

    @PostMapping("/register")
    public User Register(@RequestBody User user) {
        return userRepository.save(user);
    }
    @PostMapping("/login")
    public ResponseEntity<?> Login(@RequestBody User user) {
        User userInDb = userRepository.findByEmail(user.getEmail());
        if (userInDb != null && userInDb.getPassword().equals(user.getPassword())) {
            return ResponseEntity.ok(userInDb);
        }
        return ResponseEntity.badRequest().body("Wrong email or password");
    }
}