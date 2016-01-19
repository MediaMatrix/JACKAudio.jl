module JACKAudioTests

if VERSION >= v"0.5.0-"
    using Base.Test
else
    using BaseTestNext
end
using JACKAudio
using SampleTypes

@testset "JACK Tests" begin
    # the process callback is not part of the public API, but we want to run
    # some tests on it anyways
    # @testset "Process Callback" begin
    #     client = JackClient()
    #     alloc = @allocated JACKAudio.process(UInt32(256), client.ptr)
        # JACKAudio.process(Cint(128), reinterpret(Ptr{JackClient}, pointer_from_objref(client)))
    #     close(client)
    #     @test alloc == 0
    # end
    @testset "Opening Client" begin
        buf = Array(Float32, 5*48000)
        client = JackClient()
        source = JackSource(client, "TestSource")
        sink = JackSink(client, "TestSink")
        activate(client)
        println("CONNECT ME!")
        sleep(10)
        println("recording...")
        read!(source, buf)
        println("playing...")
        write(sink, buf)
        println("hanging out...")
        sleep(5)
        JACKAudio.deactivate(client)
        close(client)
    end
end

end # module

# module JACKAudioScratch
# using JACKAudio
# 
# client = JackClient()
# client = JackClient("Julia", active=false)
# JACKAudio.activate(client)
# pclient = reinterpret(Ptr{JackClient}, pointer_from_objref(client))
# 
# @allocated JACKAudio.process(JACKAudio.NFrames(128), pclient)
# code_llvm(JACKAudio.process, (JACKAudio.NFrames, Ptr{JackClient}))
# # activate(client)
# # source = JackSource(client, "TestSource")
# # sink = JackSink(client, "TestSink")
# # close(client)
# end

module JackScratch

using Gadfly
using JACKAudio

# 5seconds of sin
client = JackClient("SinPlayer")
sink = JackSink(client, "Out1")
activate(client)
t = collect(linspace(0f0, 5f0, 5*48000))
tone = sin(440*2pi*t)
sleep(10)
println("writing")
write(sink, tone)
println("done writing")
sleep(6)
deactivate(client)
close(client)

# loopback test
client = JackClient("LoopBack")
sink = JackSink(client, "Out1")
source = JackSource(client, "In1")
activate(client)
buf = Array(Float32, 5*48000)
sleep(10) # give time to hook things up in JACK
println("recording")
read!(source, buf)
println("done recording")
write(sink, buf)
sleep(5)
deactivate(client)
close(client)

# loopback test
client = JackClient("LoopBack")
sink = JackSink(client, "Out1")
source = JackSource(client, "In1")
activate(client)
dummybuf = Array(Float32, 5*48000)
buf = Array(Float32, 512)
println("recording")

read!(source, dummybuf)
while true
    read!(source, buf)
    write(sink, buf)
end
println("done recording")
sleep(5)
deactivate(client)
close(client)

c = JACKClient()
c = JACKClient(connect=false)
c = JACKClient(4, 4)
source = sources(c)[1]
sink = sinks(c)[1]

buf = read(source, 5s)
write(sink, buf)
JACKAudio.autoconnect(c)
JACKAudio.selfconnect(c)

end