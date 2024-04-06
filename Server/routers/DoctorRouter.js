const express = require("express");
const jwt = require("jsonwebtoken");

const authDoctor = require("../MiddleWare/doctorMiddleware");
const { doctorModule } = require("../DoctorModule/doctorModule");
const { appointMentDetail } = require("../DoctorModule/appointMentDetails");
const { scheduleTIme } = require("../DoctorModule/ScheduleTime");
const doctorRouter = express.Router();
doctorRouter.post("/doctor/signUp", async (req, res) => {
  try {
    const {
      name,
      bio,
      phoneNumber,
      specialist,
      currentWorkingHospital,
      profilePic,
      registerNumbers,
      experience,
      emailAddress,
      age,
    } = req.body;
    let existingUser = await doctorModule.findOne({ phoneNumber });

    if (existingUser) {
      return res
        .status(400)
        .json({ msg: "User already exists with this PhoneNumber" });
    }
    const newDoctor = new doctorModule({
      name,
      bio,
      phoneNumber,
      specialist,
      currentWorkingHospital,
      profilePic,
      registerNumbers,
      experience,
      emailAddress,
      age,
    });
    const savedDoctor = await newDoctor.save();
    const token = jwt.sign({ id: savedDoctor._doc }, "passwordKeyD");

    res.json({ token, ...savedDoctor._doc });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

doctorRouter.post("/tokenIsValid/doctor", async (req, res) => {
  try {
    const token = req.header("x-auth-token-D");
    if (!token) {
      return res.json(false);
    }
    const verified = jwt.verify(token, "passwordKeyD");
    if (!verified) {
      return res.json(false);
    }
    const doctor = await doctorModule.findById(verified.id);
    if (!doctor) {
      return res.json(false);
    }
    res.json(true);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

doctorRouter.get("/D", authDoctor, async (req, res) => {
  const doctor = await doctorModule.findById(req.user); //by using auth middleware
  res.json({ ...doctor._doc, token: req.token });
});

doctorRouter.post("/AppointmentModify", authDoctor, async (req, res) => {
  try {
    const { date, timeSlots, price } = req.body;

    // Check if price is provided in the request body
    if (!price) {
      return res.status(400).send({ message: "Price is required" });
    }

    const newTimeSlot = new scheduleTIme({
      date,
      timeSlots,
    });
    await newTimeSlot.save();

    const newAppointMentDetail = new appointMentDetail({
      price,
      timeSlotPicks: [
        {
          timeSlot: newTimeSlot,
        },
      ],
    });

    await newAppointMentDetail.save();

    const doctor = await doctorModule.findById(req.user);
    if (!doctor) {
      return res.status(404).send({ message: "Doctor not found" });
    }

    doctor.timeSlot.push({ appointMentDetails: [newAppointMentDetail] });
    await doctor.save();

    res
      .status(200)
      .send({ message: "Appointment updated successfully", doctor });
  } catch (error) {
    console.error(error);
    res
      .status(500)
      .send({ message: "An error occurred while modifying the appointment" });
  }
});
module.exports = doctorRouter;
