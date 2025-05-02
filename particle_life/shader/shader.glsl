#[compute]
#version 450

layout(local_size_x = 1024,local_size_y = 1 ,local_size_z = 1) in;

layout(set = 0,binding = 0,std430) restrict buffer position {
    vec2 data[];
}partilce_pos;


layout(set = 0,binding = 1,std430) restrict buffer velocity {
    vec2 data[];
}partilce_vel;



layout(set = 0,binding = 2,std430) restrict buffer Params {
    float num_boids;
    float cell_types;
    float imsize;
    float scren_x;
    float scren_y;
    float dt;
    float drag;
    float force;
    float rep_force;
    float force_dist;
    float rep_force_dist;

}params;

layout(rgba16,binding = 3) uniform image2D boid_data;

layout(set = 0,binding =4,std430) restrict buffer force {
    float data[];
}forces;


float cal_force(float dist,float range ,int poww){

    return pow(1-pow((dist/range),poww),poww);
}



void main(){
    int myindex = int(gl_GlobalInvocationID);
    vec2 mypos = partilce_pos.data[myindex];
    vec2 myvel = partilce_vel.data[myindex];

    vec2 force = vec2(0,0);

    int delta = 0;

    for (int i = 0;i < params.num_boids;i++){
        vec2 otpos = partilce_pos.data[i];
        float dist = distance(mypos,otpos);

        if(i != myindex){

            if(dist < params.force_dist){

                int f_index = (myindex % int(params.cell_types))+(i%int(params.cell_types))*int(params.cell_types);
                force -= normalize(mypos - otpos) * cal_force(dist,params.force_dist,3)*params.force *forces.data[f_index] ;
                if(dist < params.rep_force_dist){
                    force += (normalize(mypos - otpos) *cal_force(dist,params.rep_force_dist,1)) * params.rep_force;
                }

            }




        }
    }


     myvel += force * params.dt;






    mypos += myvel * params.dt;



    mypos = vec2(mod(mypos.x,params.scren_x),mod(mypos.y,params.scren_y));

    partilce_pos.data[myindex] = mypos;

    float vel = length(myvel);

    if(vel >0.1){
        float drag_forse =vel*vel* params.drag*params.dt;
        myvel -= normalize(myvel)*drag_forse;
    }

    partilce_vel.data[myindex] = myvel;

    if(any(isnan(partilce_pos.data[myindex])) || any(isinf(partilce_pos.data[myindex]))){
        partilce_pos.data[myindex] = vec2(0,0);
        partilce_vel.data[myindex] = vec2(0,0);
    }

    ivec2 ppos = ivec2(int(mod(myindex,params.imsize)),int(myindex/params.imsize));



    imageStore(boid_data,ppos,vec4(mypos.x,mypos.y,0,0));








}



