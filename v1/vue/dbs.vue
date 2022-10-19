//引入库
import GPS from "@/utils/gpstoGD";

//这里只是代码片段，需要你配合vue webpack开发
test() {
  let N = 2248.93420
  let E = 11331.99490
  const mark = GPS.gcj_encrypt(Number(this.NEToGPs(N)), Number(this.NEToGPs(E)));
  console.log(mark);
    this.center = [ mark["lon"],mark["lat"]]
    let make = [
      {center: [mark["lon"], mark["lat"]],fillColor: "rgba(255,255,255,1)",}
    ];
  //   console.log(make)
    this.markers = make
},
NEToGPs(val){
    return Math.trunc(val/100)+(val%100)/60
},
